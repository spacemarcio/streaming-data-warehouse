## Streamming Data Warehouse Architecture

![](https://github.com/spacemarcio/streaming-data-warehouse/blob/048f22429caefd85e98d6d8fb853cf9e9aa583e1/readme-images/architeture.png)

Architeture made for quick responses about buy or sell a share. Real-time data ingestion layer gives fresh to date information for the Enterprise Decision Support System. Batch processing data layer calculates strategy metrics based on past behavior.   

### Components

- [X] Stock prices stream
- [X] Kineses consumer
- [X] S3 Buckets
- [X] Airflow
- [X] EMR cluster and Jobs
- [X] Redshift Cluster

## Dataflow
1. Data comes from producer [ `stream_stock_prices.py` ] to consumer [ Kinesis Firehose]

2. Store transactional data at `stockprices-data` bucket, `transations` folder.

3. Load the new data into Redshift [ using COPY command ]

4. Daily, take the transactional data, calculate boillinger bands parameters and store processed data at `stockprices-data` bucket, `bollinger-bands` folder [ by Airflow and EMR jobs].

5. Load the processed data into Redshift cluster [ Airflow `S3ToRedshiftOperator` operator].

## How setup the Architecture?

1. Terraform files in `infrastructure` folder are responsible for: create buckets, setup Kinesis Firehose and Glue Crawler services, request a EC2 instance for Airflow and a Redshift cluster.

2. In `Airflow` folder there are files for install Docker and setup Airflow at EC2 instance. Important to notice that it's necessary to create connections to request EMRs clusters and copy data from S3 to Redshift Operators. Look at `connections.md` file.

3. In `redshift` folder there are SQL queries to create tables to recive data.

4. In `producer` folder theare scritps to prepare and emulate stock price stream events.

## Cured pain points 

The most harmless part of this system was send the data to Redshift. 

When data comes from Firehose, you just have to certify that CloudWatch logs will be store, they are very informative. I had problems based on Redshift endpoint, IAM permissions, and copy options [ variables in JSON files must be in the same order that Redshift table ].

It takes a lot of time to figure out how to load processed data from EMR to Redshift. The easy way is to use Airflow Operator, but another popular solution is to use Lambda functions and Redshift boto3 client.