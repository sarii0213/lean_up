import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

client = boto3.client('rds')
response = client.describe_db_clusters()

def start_db_cluster(event, context):
    for DBCluster in response['DBClusters']:
        print(DBCluster['DBClusterIdentifier'] + ': ' + DBCluster['Status'])
        if DBCluster['Status'] == "stopped":
            print(str(client.start_db_cluster(DBClusterIdentifier = DBCluster['DBClusterIdentifier'])))



def stop_db_cluster(event, context):
    for DBCluster in response['DBClusters']:
        print(DBCluster['DBClusterIdentifier'] + ': ' + DBCluster['Status'])
        if DBCluster['Status'] == "available":
            print(str(client.stop_db_cluster(DBClusterIdentifier = DBCluster['DBClusterIdentifier'])))
