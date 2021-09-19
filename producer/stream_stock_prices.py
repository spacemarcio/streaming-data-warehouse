"""
Code to streaming historical bitcoin registers from local
database to AWS Kinesis.

"Included here is historical bitcoin market data at 1-min 
intervals for select bitcoin exchanges where trading takes 
place." - Zielak

Source:
https://www.kaggle.com/mczielinski/bitcoin-historical-data
"""

import boto3

import pandas as pd
import json

if __name__ == '__main__':

    # 1. GET DATA

    data = pd.read_parquet("../data/stockPrices.parquet")

    # 2. PREPARE EVENTS

    events = data.to_json(orient = 'records')
    events = json.loads(events)

    # 3. LOAD EVENTS

    client = boto3.client('firehose', region_name='us-east-2')

    def load_record(event):

        eventStream = (json.dumps(event) + '\n').encode('utf-8') 

        response = client.put_record(
            DeliveryStreamName='stockprices-stream',
            Record = {
                'Data': eventStream
            }
        )

        print(event)
        
        return response

    # 4. STREAMING
    print("STARTING STREAMING")

    for event in events:
        
        print(event)
        
        load_record(event)