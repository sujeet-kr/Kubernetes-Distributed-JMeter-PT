#!/usr/bin/env bash

working_dir=`pwd`

source ./perf-load-gen.cfg

thePVVolIDValue=`aws ec2 describe-volumes  --filters Name=tag:PVPerfTesting,Values=InfluxDBPV Name=tag:KubernetesCluster,Values=${KOPS_CLUSTER_NAME} --query 'Volumes[*].{ID:VolumeId}' --region ${AWS_REGION} --output text`

echo "Persisstent value is ${thePVVolIDValue}"

echo "Verify kubectl installation"

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' not found in PATH"
    exit
fi

kubectl version --short

echo "List of namespaces in the Kubernetes cluster:"

echo

kubectl get namespaces | grep -v NAME | awk '{print $1}'

echo

#Check If namespace exists
kubectl get namespace ${thenamespace} > /dev/null 2>&1

if [ $? -gt 0 ]
then
  echo
  echo "Creating Namespace: ${thenamespace}"

  kubectl create namespace ${thenamespace}

  echo "Namspace ${thenamespace} has been created"
  echo
  sleep 2s

  kubectl get namespaces | grep -v NAME | awk '{print $1}'
  echo
fi

echo "Creating Persistent Volume"
cat ${working_dir}/kubernetes/persistent-volume/persistent-vol.yaml | sed s/\$\$PVVolumeID/${thePVVolIDValue}/ | kubectl create -f -
# kubectl create -f $working_dir/kubernetes/persistent-volume/persistent-vol.yaml
echo

echo "Creating Persistent Volume Claim"
kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/persistent-volume/persistent-vol-claim.yaml
echo

echo "Creating Jmeter Worker nodes"

nodes=`kubectl get no | egrep -v "master|NAME" | wc -l`

echo

echo "Number of worker nodes on the cluster: " ${nodes}

echo

echo "Creating Jmeter Worker Deployment and Service"

echo

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/jmeter-worker/jmeter_worker_deploy.yaml

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/jmeter-worker/jmeter_worker_svc.yaml

echo "Creating Jmeter Master Deployment and ConfigMap"

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/jmeter-master/jmeter_master_configmap.yaml

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/jmeter-master/jmeter_master_deploy.yaml

echo "Creating Influxdb Deployment Service"

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/influxdb/jmeter_influxdb_configmap.yaml

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/influxdb/s3_backup_secret.yaml

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/influxdb/jmeter_influxdb_deploy.yaml

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/influxdb/jmeter_influxdb_svc.yaml

echo "Creating Grafana Deployment"

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/grafana/jmeter_grafana_deploy.yaml

kubectl create -n ${thenamespace} -f ${working_dir}/kubernetes/grafana/jmeter_grafana_svc.yaml

echo "Displaying all Objects present in ${thenamespace} "

echo

kubectl get -n ${thenamespace} all

echo "Creating the Database..."

./create_db.sh

echo
echo
echo "Grafana Dashboard URL for the Performance Testing Infra"
echo `kubectl -n fclte describe svc jmeter-grafana | grep "LoadBalancer Ingress" | awk '{print $3}'`

