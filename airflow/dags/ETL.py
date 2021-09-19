from os import getenv

from datetime import timedelta

from airflow import DAG
from airflow.providers.amazon.aws.operators.emr_create_job_flow import EmrCreateJobFlowOperator
from airflow.providers.amazon.aws.sensors.emr_job_flow import EmrJobFlowSensor
from airflow.providers.amazon.aws.transfers.s3_to_redshift import S3ToRedshiftOperator
from airflow.utils.dates import days_ago

S3_BUCKET = getenv("S3_BUCKET", "stockprices-data")
S3_KEY = getenv("S3_KEY", "bollinger-bands")
REDSHIFT_TABLE = getenv("REDSHIFT_TABLE", "bollingerbands")

SPARK_STEPS = [
    {
        'Name': 'stockprices_processing',
        'ActionOnFailure': 'TERMINATE_CLUSTER',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': ['spark-submit',
                    '--master', 'yarn',
                    '--deploy-mode', 'cluster',
                    's3://stockprices-code/calculate_bollinger_bands.py'
            ]
        },
    }
]

JOB_FLOW_OVERRIDES = {
    'Name': 'stockprices_processing',
    'ReleaseLabel': 'emr-6.3.0',
    'LogUri': 's3://stockprices-emr-logs',
    'VisibleToAllUsers': True,
    'Instances': {
        'InstanceGroups': [
            {
                'Name': 'Main node',
                'Market': 'SPOT',
                'InstanceRole': 'MASTER',
                'InstanceType': 'm5.xlarge',
                'InstanceCount': 1,
            },
            {
                'Name': 'Executor node',
                'Market': 'SPOT',
                'InstanceRole': 'CORE',
                'InstanceType': 'm5.xlarge',
                'InstanceCount': 2,
            }
        ],
        'KeepJobFlowAliveWhenNoSteps': False,
        'TerminationProtected': False,
    },
    'Configurations': [
        {
            "Classification": "hive-site",
            "Properties": {
                "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
            }
        },
        {
            "Classification":"spark-hive-site",
            "Properties":{
                "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
            }
        }
    ],
    'Applications': [
        {
            'Name': 'Hadoop'
        },
        {
            'Name': 'Hive'
        },
        {
            'Name': 'Pig'
        },
        {
            'Name': 'Hue'
        },
        {
            'Name': 'Spark'
        },
        {
            'Name': 'Livy'
        }
    ],
    'Steps': SPARK_STEPS,
    'JobFlowRole': 'EMR_EC2_DefaultRole',
    'ServiceRole': 'EMR_DefaultRole',
}

with DAG(
    dag_id='stockprices_processing',
    default_args={
        'owner': 'marcio',
        'depends_on_past': False,
        'email': ['delucasmarcio@gmail.com'],
        'email_on_failure': False,
        'email_on_retry': False,
    },
    dagrun_timeout=timedelta(hours=1),
    start_date=days_ago(1),
    schedule_interval='@daily',
    tags=['stockprices'],
) as dag:

    create_bollinger_bands = EmrCreateJobFlowOperator(
        task_id='create_job_flow',
        job_flow_overrides=JOB_FLOW_OVERRIDES,
        aws_conn_id='aws_default',
        emr_conn_id='emr_default',
    )

    wait_job_finish = EmrJobFlowSensor(
        task_id='check_job_flow',
        job_flow_id=create_bollinger_bands.output,
        aws_conn_id='aws_default',
    )

    load_data_to_redshift = S3ToRedshiftOperator(
        task_id='transfer_s3_to_redshift',
        s3_bucket=S3_BUCKET,
        s3_key=S3_KEY,
        schema="PUBLIC",
        table=REDSHIFT_TABLE,
        copy_options=[
            "FORMAT as CSV",
            "DELIMITER as '\t'",
            "IGNOREHEADER as 1" # first line is the header
        ],
        aws_conn_id='aws_default',
        redshift_conn_id='redshift_default'
    )

    create_bollinger_bands >> wait_job_finish >> load_data_to_redshift