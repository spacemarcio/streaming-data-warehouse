from pyspark.sql import SparkSession

import pyspark.sql.functions as SF
from pyspark.sql.window import Window
import pyspark.sql.types as ST

spark = SparkSession.builder \
    .appName('stock-prices-processing') \
    .enableHiveSupport() \
    .getOrCreate()

stockPrices = spark.sql("""
select 
    *
from
    stockprices.transactions
""")

win = Window \
    .partitionBy('share') \
    .orderBy(SF.col("transaction_date").cast('long')) \
    .rowsBetween(-20, 0) # 20 rows before equals 20 days ago

bollingerParameters = stockPrices.select(
    'share',
    'transaction_date',
    SF.avg('price').over(win).alias('mean_period'),
    SF.stddev('price').over(win).alias('sd_period')
).distinct()

bollingerBands = bollingerParameters.select(
    'share',
    SF.col('transaction_date').alias('bollinger_date'),
    (SF.col('mean_period') + 2 * SF.col('sd_period')).alias('upper_band'),
    (SF.col('mean_period') - 2 * SF.col('sd_period')).alias('lower_band')
)

bollingerBands \
    .repartition(1) \
    .write \
    .csv(
        path = "s3://stockprices-data/bollinger-bands", 
        sep='\t',
        header='true',
        compression='none',
        mode = 'overwrite'
    )