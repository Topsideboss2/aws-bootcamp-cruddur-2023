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

To build the image run
```
docker build -t backend-flask ./backend-flask
```

To run the image
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

![Running Backend](../_docs/assets/AWSBootcampFrontendURL(gitpod).png)

