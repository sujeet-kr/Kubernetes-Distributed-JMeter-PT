#!/usr/bin/env bash

working_dir=`pwd`
source ./perf-load-gen.cfg

## Create jmeter database in Influxdb

echo "Creating Influxdb Jmeter Database"

##Wait until Influxdb Deployment is up and running
influxdb_status=`kubectl get po -n ${thenamespace} | grep influxdb-jmeter | awk '{print $2}'`

while [ "${influxdb_status}" != "1/1" ]; do
   sleep 5s
   echo "Waiting for InfluxDB Pod to be ready ..."
   influxdb_status=`kubectl get po -n ${thenamespace} | grep influxdb-jmeter | awk '{print $2}'`
done

echo "InfluxDB Pod Status"
echo `kubectl get po -n ${thenamespace} | grep influxdb-jmeter`

influxdb_pod=`kubectl get po -n ${thenamespace} | grep influxdb-jmeter | awk '{print $1}'`
# kubectl exec -it -n $thenamespace $influxdb_pod -- influx -execute 'CREATE DATABASE jmeter'

kubectl exec -it -n ${thenamespace} ${influxdb_pod} -- aws s3 cp s3://${S3_BUCKET}/${BACKUP_ARCHIVE_NAME} ${BACKUP_ARCHIVE_LOCATION}
kubectl exec -it -n ${thenamespace} ${influxdb_pod} -- tar -xvzf ${BACKUP_ARCHIVE_LOCATION} -C .
kubectl exec -it -n ${thenamespace} ${influxdb_pod} -- influxd restore -portable -db ${DATABASE_NAME} ${BACKUP_FOLDER}${BACKUP_NAME}

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"
grafana_pod=`kubectl get po -n ${thenamespace} | grep jmeter-grafana | awk '{print $1}'`

kubectl exec -it -n ${thenamespace} ${grafana_pod} -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'