# Airflow Connections

## Passo a passo

 - Acessar aba de Admin
 - Acessar Connections
 - Adicionar 3 novas conexões:
    - aws_default
    - emr_default
    - redshift_default

### aws_default

 - Conn Id     : aws_default
 - Conn Type   : Amazon Web Services
 - Login       : Access key ID
 - Password    : Secret access key
 - Extra       : {"region_name": "us-east-2"}

### emr_default

 - Conn Id     : emr_default
 - Conn Type   : Elastic MapReduce
 - Login       : Access key ID
 - Password    : Secret access key

### redshift_default

 - Conn Id     : redshift_default
 - Conn Type   : Postgres
 - Host        : <<`REDSHIFT_CLUSTER_NAME`>>.<<`TOKEN`>>.<<`AWS_REGION`>>.redshift.amazonaws.com
 - Schema      : Redshift database name
 - Login       : Redshift master login
 - Password    : Redshift master password
 - Port        : 5439