
============Build, tag and push the base image============

		`docker build --tag="<docker-registry>/jmeter-base:latest"`
		`docker push <docker-registry>/jmeter-base:latest`


============Build, tag and push the master image===========

		`docker build --tag="<docker-registry>/jmeter-master:latest"`
		`docker push <docker-registry>/jmeter-master:latest`


============Build, tag and push the salve image:===========

		`docker build --tag="<docker-registry>/jmeter-worker:latest"` 
		`docker push <docker-registry>/jmeter-worker:latest`

====================Create Cluster=========================

		* cd to the root folder 
		`./create_cluster.sh`

=====================Execute Test==========================

		* cd to the root folder
		`./execute_test.sh`
		* provide the location of the framework either in source code or present locally
		* provide the main jmx file name
		* provide instruction (Y/N) to update framework, if already present in the cluster

