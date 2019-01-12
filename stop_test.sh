#!/usr/bin/env bash
#bash to stop test execution

working_dir=`pwd`
source ./perf-load-gen.cfg

jmeter_master=`kubectl get po -n ${thenamespace} | grep jmeter-master | awk '{print $1}'`
echo "Sending stop command to ${jmeter_master}"
kubectl -n ${thenamespace} exec -it ${jmeter_master} bash /jmeter/apache-jmeter-5.0/bin/stoptest.sh