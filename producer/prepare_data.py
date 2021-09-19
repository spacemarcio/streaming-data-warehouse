"""
Taking data from:

https://www.kaggle.com/mysarahmadbhat/stock-prices
"""

import boto3

import pandas as pd
import json

if __name__ == '__main__':

    # 1. GET DATA

    dataRaw = pd.read_csv("../data/stock_prices.csv")

    # 2. FIXING LAYOUT

    dataRaw = dataRaw.rename(str.lower, axis='columns')

    dataRaw = dataRaw[['symbol','date','open','volume']]

    dataRaw = dataRaw.rename(columns={
        'symbol': 'share',
        'date': 'transaction_date',
        'open': 'price',
        'volume': 'volume',
        })

    data = dataRaw.drop(
        dataRaw.index[dataRaw.isnull().any(axis=1)],
        0,
        inplace=False
    ).reset_index(drop=True)

    data = data.sort_values(by=['transaction_date'])

    # 3. SAVING TO PARQUET

    data.to_parquet('../data/stockPrices.parquet')