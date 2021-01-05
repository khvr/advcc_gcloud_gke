# poller
This is the poller application developed for CSYE 7125 course. We have used node.js and express.js to create Kafka services for the application. We are using MySql for the database.
## Team Information

| Name | NEU ID | Email Address |
| --- | --- | --- |
| Viraj Rajopadhye| 001373609 | rajopadhye.v@northeastern.edu |
| Pranali Ninawe | 001377887 | ninawe.p@northeastern.edu |
| Harsha vardhanram kalyanaraman | 001472407 | kalyanaraman.ha@northeastern.edu | 

In order to run the application, navigate to the webapp folder install dependencies "npm install" and run "npm start".

Jenkins is setup to push docker images to docker hub. The images are tagged with both git commit number and latest tag.

The latest image can be pulled and run locally.

if running the application locally, create a .env file at the root of the project with the following variables

```bash
DB_USERNAME =<username>
DB_HOST =<hostname>
DB_NAME =<Database Name>
DB_PASS =<Database password>
OW_API_KEY =<Weather API Key>
WEATHER_POLL_TIME =<Polling time in minutes>
```

# Run Docker image
```bash
docker run --network=host -p 3001:3001 <DockerHubID>/poller:latest 
```

# Jenkins setup
1. A private repository should be created at Dockerhub
2. Commit to a webapp branch will trigger a pipeline to build and push the image to that private repository.

# Helm Installation

```bash
helm install poller ./helm/poller-helm/ --set DB_USERNAME=<DBUSERNAME>,DB_PASS=<DBPASSWORD>,DB_HOST_POLLER=<DB_HOST_POLLER>,imageCredentials.Docker_username=<DOCKERUSERNAME>,imageCredentials.Docker_password=<DOCKERPASSWORD>,OW_API_KEY=<OWKEY>,pollerDockerImage=<BACKEND_IMAGE_POLLER>
```