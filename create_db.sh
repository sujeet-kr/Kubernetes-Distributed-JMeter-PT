#!/usr/bin/env bash

working_dir=`pwd`

#Get namesapce variable
thenamespace=`awk '{print $NF}' $working_dir/thenamespace`

## Create jmeter database in Influxdb

echo "Creating Influxdb Jmeter Database"

##Wait until Influxdb Deployment is up and running
influxdb_status=`kubectl get po -n $thenamespace | grep influxdb-jmeter | awk '{print $2}'`

while [ "$influxdb_status" != "1/1" ]; do
   sleep 5s
   echo "Waiting for InfluxDB Pod to be ready ..."
   influxdb_status=`kubectl get po -n $thenamespace | grep influxdb-jmeter | awk '{print $2}'`
done

echo "InfluxDB Pod Status"
echo `kubectl get po -n $thenamespace | grep influxdb-jmeter`
echo

influxdb_pod=`kubectl get po -n $thenamespace | grep influxdb-jmeter | awk '{print $1}'`
kubectl exec -it -n $thenamespace $influxdb_pod -- influx -execute 'CREATE DATABASE jmeter'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"
grafana_pod=`kubectl get po -n $thenamespace | grep jmeter-grafana | awk '{print $1}'`

kubectl exec -it -n $thenamespace $grafana_pod -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'