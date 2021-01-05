# webapp

This is the backend of the web application developed for CSYE 7125 course. We have used node.js and express.js to create REST API endpoints for the application. We are using MySql for the database.

## Team Information

| Name                           | NEU ID    | Email Address                    |
| ------------------------------ | --------- | -------------------------------- |
| Viraj Rajopadhye               | 001373609 | rajopadhye.v@northeastern.edu    |
| Pranali Ninawe                 | 001377887 | ninawe.p@northeastern.edu        |
| Harsha vardhanram kalyanaraman | 001472407 | kalyanaraman.ha@northeastern.edu |

<br />

* In order to run the application, clone the webapp ($ cd git@github.com:CSYE7125/webapp.git) navigate to the webapp (cd webapp) folder install dependencies "npm install" and run "npm start".

* Jenkins is setup to push docker images to docker hub. The images are tagged with both git commit number and latest tag.

* The latest image can be pulled and run locally.

* if running the application locally, create a .env file at the root of the project with the following variables

```bash
DB_USERNAME =<username>
DB_HOST =<Database Endpoint>
DB_NAME =<Database Name>
DB_PASS =<Database password>
BROKER1=<Kafka_broker 1 Endpoint>:<port>
BROKER2=<Kafka_broker 2 Endpoint>:<port>
BROKER3=<Kafka_broker 3 Endpoint>:<port>
```
The project requires running a kafka cluster locally which can be brought up using the following docker compose file authored by simplesteph


https://github.com/simplesteph/kafka-stack-docker-compose/blob/master/zk-multiple-kafka-multiple.yml

```bash
docker-compose -f zk-single-kafka-single.yml up
docker-compose -f zk-single-kafka-single.yml down
```

# Docker Commands using Dockerfile

## Docker build
```bash
$ docker build <username>/<repo_path>:<tag> .
```
## Docker run
```bash
$ docker run --env-file <path_to_env_file> -d -p <your_host_port>:<container_app_port> <username>/<repo_path>:<tag> 
```
## Docker stop
```bash
$ docker stop <username>/<repo_path>:<tag> 
```
## Docker push
```bash
Note: if its a private repo run 
$ docker login --username=<user username> --email=<user email address>
$ docker push <username>/<repo_path>:<tag>
```
## Docker kill
```bash
$ docker kill <container_name or non_repeating_prefix_id>
```
## Docker Remove all containers and images
```bash
$ docker rm $(docker ps -a -q)
$ docker rmi $(docker images -a -q)
```

# Jenkins setup

1. A private repository should be created at Dockerhub
2. Commit to a webapp branch will trigger a pipeline to build and push the image to that private repository
3. The pipeline is extended to run helm upgrade command to deploy changes to the cluster whenever there's change to the source code

Note: The Jenkins pipeline setup can be found in this repo: https://github.com/CSYE7125/jenkins

# Horizontal pod auto scaler

1. The webapp is deployed with the HPA resource
2. To put load on the webapp to trigger HPA
```bash
$ kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -n <webapp-namespace> -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://<webapp-service>/health; done"
```

# Helm Installation

```bash
$ helm install webapp ./helm/webapp-helm/ --set DB_HOST_WEBAPP=<DB_HOST_WEBAPP>,
DB_PASS=<DBPASSWORD>,
DB_USERNAME=<DBUSERNAME>,   
imageCredentials.Docker_username=<DOCKERUSERNAME>,
imageCredentials.Docker_password=<DOCKERPASSWORD or DOCKER_ACCESS_TOKEN>,
webappIngress.domainName=<WEBAPP_DOMAIN>,
webappIngress.subDomainName=<WEBAPP_SUB_DOMAIN>
webappDockerImage=<BACKEND_IMAGE_WEBAPP>
```

## values.yaml

| Root               | Level 1         | Level 2                 | Level 3             | Description                                                                                                                                                                                                                    | Default                      |
|--------------------|-----------------|-------------------------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| namespace          | name            |                         |                     | Namespace name where the webapp resources will be deployed                                                                                                                                                                     | backend-webapp               |
| serviceAccount     | name            |                         |                     | Name of service account attached to the pods deployed                                                                                                                                                                          | sa-backend                   |
| role               | name            |                         |                     | Name of the the role having limited rules                                                                                                                                                                                      | role-backend                 |
| role_binding       | name            |                         |                     | The Name of the role biding resource which combines the role with service account                                                                                                                                              | sa-backend-bind-role-backend |
| DB_HOST_WEBAPP     |                 |                         |                     | Database endpoint                                                                                                                                                                                                              |                              |
| DB_NAME_WEBAPP     |                 |                         |                     | Database Name                                                                                                                                                                                                                  | csye7125webapp               |
| DB_USERNAME        |                 |                         |                     | Database username                                                                                                                                                                                                              |                              |
| DB_PASS            |                 |                         |                     | Database password                                                                                                                                                                                                              |                              |
| KAFKA_BROKER_A_svc |                 |                         |                     | kafka broker A endpoint eg: kafka1service.<namespace_name>:<port>                                                                                                                                                              | kafka1.kafka-prereq:9092     |
| KAFKA_BROKER_B_svc |                 |                         |                     | kafka broker B endpoint eg: kafka1service.<namespace_name>:<port>                                                                                                                                                              | kafka2.kafka-prereq:9092     |
| KAFKA_BROKER_C_svc |                 |                         |                     | kafka broker C endpoint eg: kafka1service.<namespace_name>:<port>                                                                                                                                                              | kafka3.kafka-prereq:9092     |
| imageCredentials   | registry        |                         |                     | The endpoint of the container registry                                                                                                                                                                                         | https://index.docker.io/v1/  |
|                    | Docker_username |                         |                     | Private repository docker username                                                                                                                                                                                             |                              |
|                    | Docker_password |                         |                     | Private repository docker password/ access token                                                                                                                                                                               |                              |
| webappDockerImage  |                 |                         |                     | Container image path of the webapp deployment                                                                                                                                                                                  |                              |
| webappDeployment   | replicationSet  | replicas                |                     | Replicas is the number of desired replicas. This is a pointer to distinguish between explicit zero and unspecified. Defaults to 1                                                                                              | 3                            |
|                    |                 | progressDeadlineSeconds |                     | progressDeadlineSeconds denotes the number of seconds the Deployment controller waits before indicating (in the Deployment status) that the Deployment progress has stalled.                                                   | 120                          |
|                    |                 | minReadySeconds         |                     | The minimum number of seconds for which a newly created pod should be ready without  any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready) | 30                           |
|                    |                 | rollingUpdate           | maxSurge            | MaxSurge is an optional field that specifies the maximum number of Pods that can be created over the desired number of Pods.                                                                                                   | 1                            |
|                    |                 |                         | maxUnavailable      | maxUnavailable is an optional field that specifies the maximum number of Pods that can be unavailable during the update process.                                                                                               | 0                            |
|                    | pod             | readinessProbe          | initialDelaySeconds | Number of seconds after the container has started before liveness probes are initiated                                                                                                                                         | 15                           |
|                    |                 |                         | periodSeconds       | How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.                                                                                                                                        | 60                           |
|                    |                 | livenessProbe           | initialDelaySeconds | Number of seconds after the container has started before liveness probes are initiated.                                                                                                                                        | 15                           |
|                    |                 |                         | periodSeconds       | How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.                                                                                                                                        | 60                           |
| webappService      | type            |                         |                     | Type of service resource                                                                                                                                                                                                       | ClusterIP                    |
| webappIngress      | domainName      |                         |                     | Domain name to reach the webapp through ingress resource                                                                                                                                                                       |                              |
|                    | subDomainName   |                         |                     | Sub Domain name to reach the webapp through ingress resource                                                                                                                                                                   |                              |