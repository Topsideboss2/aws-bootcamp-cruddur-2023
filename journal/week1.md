# Week 1 — App Containerization
## Topics
* [Containerize Backend and Frontend Individually]()
* [Container Orchestration of Backend and Frontend using docker-compose]()
* [Create the Backend and Frontend Notification Feature in Flask and React respectively]()
* [Accessing the API through Open API]()
* [Configure DynamoDB and PostgreSQL]()
* [Running the Dockerfile CMD as an external script]()
* [Pushing and tagging an image to Dockerhub]()
* [Installing and running docker containers on local machine]()

### Containerization of Frontend and Backend

#### What is a Dockerfile?
 A dockerfile (saved as `Dockerfile`) is a file that contains all the commands a user would call on the command line to assemble an image.
 
### Backend Dockerfile
Before we run the Backend Dockerfile we need the `requirements.txt` file where the dockerfile will be instructed to install the contents of this requirements file.

`requirements.txt` file:
```
flask
flask-cors
```

`Dockerfile` itself:
```
FROM python:3.10-slim-buster

ENV PORT=4567

WORKDIR /backend-flask

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```

***Quick sidenote***: I had to include the line `ENV PORT=4567` because when running the dockerfile in my local environment I was having challenges opening the port to the public 

To build the image:
```
docker build -t backend-flask ./backend-flask
```

To run a container as an instance of the image, you need to specify some environment variables such as FRONTEND_URL and BACKEND_URL:
```
docker run --rm -p 4567:4567 -it -e FRONTEND_URL="*" -e BACKEND_URL="*" backend-flask 
```

![Running Backend](../_docs/assets/AWS%20Bootcamp%20Backend%20URL.png)

### Frontend Dockerfile
This was similar to backend and didn't need as many commands.

`Dockerfile` :
```
FROM node:16.18

ENV PORT=3000

COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]
```

***Quick Sidenote***: Here, the port was already specified as `ENV PORT=3000` and therefore there was no challenges encountered.

![Running Frontend](../_docs/assets/AWSBootcampFrontendURL(gitpod).png)

To check images and running container ids:
```
docker ps
docker images
```

Learned that frontend needs npm installed first. Run:
```
npm i
```
Or simplify workload by adding `npm install` to gitpod.yml to avoid running it manually everytime after launch of giptod.
```
...
 - name: Initialize Frontend and Backend
    init: |
      gp sync-await aws
      cd /workspace/aws-bootcamp-cruddur-2023/backend-flask
      pip3 install -r requirements.txt
      cd /workspace/aws-bootcamp-cruddur-2023/frontend-react-js
      npm i  
...
```
Also learned that with vs code one can attach a shell of a container and add environment variables in the shell of the container

### Docker-compose

Learned that to run multiple containers in docker, we use `docker compose up` or `docker-compose up`

To kill these containers use the `docker compose down` or `docker-compose down`
Or you could simply right-click on the file in VS Code and choose "Compose Up" or "Compose Down" as you please

The file is `docker-compose.yml`:
```
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js
networks: 
  internal-network:
    driver: bridge
    name: cruddur

```

### Creating The Backend and Frontend Notification Feature

When logging in to the web application the notification feature does not work and needs to be added as a functionality

![](../_docs/assets/AWSLoginPage.png)

After following the [YoutubeLink](https://www.youtube.com/watch?v=k-_o0cCpksk&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=27) by [AndrewBrown](https://twitter.com/andrewbrown?s=21&t=xmLPQvVKkEScBoXv2ELt9A), the link was up and running

![](../_docs/assets/AWSNotificationsPage.png)

### Configure DynamoDB and PostgreSQL

Modify the `docker-compose.yml` file:

```
...
  dynamodb-local:
    # https://stackoverflow.com/questions/67533058/persist-local-dynamodb-data-in-volumes-lack-permission-unable-to-open-databa
    # We needed to add user:root to get this working.
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data
...

...
volumes:
  db:
    driver: local
```

Using postgresql CLI:
```
psql -h localhost -U postgres
```

![](../_docs/assets/PostgreSQL.png)

