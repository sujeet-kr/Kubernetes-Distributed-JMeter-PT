
============Build, tag and push the base image============

		`docker build --tag="<docker-registry>/jmeter-base:latest"`
		`docker push <docker-registry>/jmeter-base:latest`


============Build, tag and push the master image===========

		`docker build --tag="<docker-registry>/jmeter-master:latest"`
		`docker push <docker-registry>/jmeter-master:latest`


============Build, tag and push the worker image:===========

		`docker build --tag="<docker-registry>/jmeter-worker:latest"` 
		`docker push <docker-registry>/jmeter-worker:latest`


============Build, tag and push the grafana image:===========

		`docker build --tag="<docker-registry>/jmeter-grafana:latest"` 
		`docker push <docker-registry>/jmeter-grafana:latest`


============Update the docker registry in the deploy files:===========
		
		`jmeter-master` 
		`jmeter-worker`
		`jmeter-grafana`		
		
====================Create Cluster=========================

		* make sure the cluster is created in AWS before running the shell script
		* make sure persistance EBS volume is created for persisting InfluxDB data for Grafana, before creating the cluster
		* TEMP: update the EBS volume's volume-id in influx-db deploy manifest
		* Refer to https://github.com/sujeet-kr/kops-performance-testing-provisioning to create the cluster in AWS
		* cd to the root folder 
		`./create_cluster.sh`

====================Create Database in Influx DB=========================

		* After the cluster is created and running, create the database jmeterdb inside influxdb
		* cd to the root folder and run
		`./create_db.sh`

=====================Execute Test==========================

		* To start the Grafana dashboard get the loadbalancer ingress url - this is the url for Grafana
		* Use `kubectl -n <thenamespace> describe svc <grafana-service-name>`
		* Load the Grafana dashboard for which the json file is available in this repo

=====================Stop Test==========================

		* cd to the root folder
		`./stop_test.sh`

