#!/bin/bash 

mkdir ./dags ./logs ./plugins
echo "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=0" > .env
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.1.3/docker-compose.yaml'
docker-compose up airflow-init
docker-compose up -d