## Streamming Data Warehouse Architecture

![](https://github.com/spacemarcio/streaming-data-warehouse/blob/048f22429caefd85e98d6d8fb853cf9e9aa583e1/readme-images/architeture.png)


### Components

- [X] Stock prices stream
- [X] Kineses consumer
- [X] S3 Buckets
- [X] Airflow
- [X] EMR cluster and Jobs
- [X] Redshift Cluster

### Dataflow
1. Data comes from producer [ `stream_stock_prices.py` ] to consumer [ Kinesis Firehose]

2. Store transactional data at `stockprices-data` bucket, `transations` folder.

3. Load the new data into Redshift [ using COPY command ]

4. Daily, take the transactional data, calculate boillinger bands parameters and store processed data at `stockprices-data` bucket, `bollinger-bands` folder [ by Airflow and EMR jobs].

5. Load the processed data into Redshift cluster [ Airflow `S3ToRedshiftOperator` operator].

6. Data can be queried anytime and are stay fresh to date.