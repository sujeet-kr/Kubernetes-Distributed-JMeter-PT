#!/usr/bin/env bash

jmeter_bin_address='/jmeter/apache-jmeter-5.0/bin'

working_dir=`pwd`

# The all the config variables
source ./perf-load-gen.cfg

echo "###################################################################"
echo "###################################################################"
echo
echo "Sujeet's Distributed Performance Testing Platform"
echo
echo "###################################################################"
echo "###################################################################"

echo
echo

read -p 'Enter path to the root of the Performance testing framework : ' frameworkPath
echo
read -p 'Enter the Jmeter test file name (.jmx) : ' jmx
echo
read -p 'Enter Rewrite existing framework Y/N : ' rewriteFrameworkFlag
echo

if [ ! -d "${frameworkPath}" ];
then
    echo "Framework was not found in the provided PATH"
    echo "Kindly check and input the correct framework path"
    exit
fi

if ! [ "${rewriteFrameworkFlag}" == "Y" -o "${rewriteFrameworkFlag}" == "N" ]
then
    echo "Wrong input! please enter valid input for Rewrite existing framework Y/N"
    echo
    exit
fi

#Get Master pod details

master_pod=`kubectl get po -n ${thenamespace} | grep jmeter-master | awk '{print $1}'`
worker_pods=`kubectl get po -n ${thenamespace} | grep jmeter-worker | awk '{print $1}'`

echo "Test will be executed from : "

frameworkFolder=$(basename ${frameworkPath})
echo "${master_pod}:/${jmeter_bin_address}/${frameworkFolder}"

echo
echo "Worker pods in use for the test: "
echo  ${worker_pods}
echo

echo "Checking if test framework is already available in the pod"
echo

frameworkFolderExists=`kubectl exec -it -n ${thenamespace} ${master_pod} -- /bin/bash -c "if [ -d '/${jmeter_bin_address}/${frameworkFolder}' ]; \
        then echo 'TRUE'; else echo 'FALSE'; fi"`

echo "Framework Folder Exists: " ${frameworkFolderExists}
echo "Rewrite Flag: " ${rewriteFrameworkFlag}
echo

if [[ "${frameworkFolderExists}" == *FALSE* || "${rewriteFrameworkFlag}" == "Y" ]]
then 
        kubectl cp ${frameworkPath} -n ${thenamespace} ${master_pod}:${jmeter_bin_address} 
        echo 'Framework copied to Master Pod: ' ${master_pod}
        echo
        for eachPod in ${worker_pods}; do
                kubectl cp ${frameworkPath} -n ${thenamespace} ${eachPod}:${jmeter_bin_address}; echo "Framework copied to Worker Pod: " ${eachPod}; echo;
        done
fi


echo
echo "Checking if load_test runner is available"

kubectl exec -it -n ${thenamespace} ${master_pod} -- /bin/sh -c \
        "if [ ! -f '/jmeter/load_test' ]; then echo 'Move load_test file to jmeter directory and change permissions'; \
        cp -r /load_test /jmeter/load_test; \
        chmod 755 /jmeter/load_test; \
        else echo 'File present Changing the permissions'; \
        chmod 755 /jmeter/load_test; fi"

echo
## Echo Starting Jmeter load test
echo "###################################################################"
echo "Starting Performance Tests"
echo "###################################################################"
echo

kubectl exec -it -n ${thenamespace} ${master_pod} -- /jmeter/load_test ${jmeter_bin_address}/${frameworkFolder}/${jmx}

