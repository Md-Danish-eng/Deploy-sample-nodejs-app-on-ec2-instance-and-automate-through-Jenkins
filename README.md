
# PROJECT TITLE:

Create a docker image for sample nodejs app and deploy to ec2-instance & then create a pipeline for this.

* First install Docker and Jenkins and Git on your machine:

sudo apt-get install docker.io -y #For docker

docker --version #to check version of docker

sudo apt-get install git #For git

git --version #to check version of git 

sudo apt-get update #install jenkins on ubuntu

sudo apt-get install openjdk-8-jdk

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add - 

It returns OK

sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' 

sudo apt install jenkins 

sudo systemctl start jenkins 

sudo systemctl status jenkins

Now jenkins is ready hit the public-ip of your machine with port no :8080
in your chrome browser.

then copy the path and go to inside your vm and Type

cat /var/lib/jenkins/secrets/initialAdminPassword 

you will get a password paste the password and configure it.

go with installed suggested plugins and enter your <name> <set-your-password> <enter-your-email>

next next < your jenkins Dashboard is ready for use >

* Create the Node.js app

First, create a new directory where all the files would live. In this directory create a package.json file that describes your app and its dependencies.

I create nodeapp directory for this 

mkdir nodeapp

Go inside this directory

cd nodeapp/

create a package.json file here

# vi package.json

{
  "name": "docker_web_app",
  "version": "1.0.0",
  "description": "Node.js on Docker",
  "author": "Md-Danish",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.16.1"
  }
}

:wq!

With your new package.json file, run < npm install > this will generate a package-lock.json file which will be copied to your Docker image.

Then, create a server.js file that defines a web app using the Express.js framework.

# vi server.js

'use strict';

const express = require('express');

// Constants
const PORT = 9080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World i am nodejs');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

:wq!

* Creating a Dockerfile:

# vi Dockerfile

FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 9080
CMD [ "node", "server.js" ]

:wq!

Create a .dockerignore file in the same directory as your Dockerfile:

# vi .dockerignore

node_modules
npm-debug.log

:wq!

# Building your image:

docker build . -t <your dockerhub-username>/node-web-app

Your image will now be listed by Docker:

# docker images

REPOSITORY                 TAG       IMAGE ID       CREATED        SIZE
mddanish123/node-web-app   latest    bf36a1ae658d   2 hours ago    911MB

# Run the image:

docker run -p 49167:9080-d <your dockerhub-username>/node-web-app

# docker ps

CONTAINER ID   IMAGE                      COMMAND                  CREATED       STATUS       PORTS                                         NAMES
1d7441d4a41a   mddanish123/node-web-app   "docker-entrypoint.s…"   2 hours ago   Up 2 hours   0.0.0.0:49167->9080/tcp, :::49167->9080/tcp   cool_vaughan 

# docker logs <container id>

Running on http://0.0.0.0:9080

# Enter the container
$ docker exec -it <container id> /bin/bash

do ls

Dockerfile     README.md    node_modules    package-lock.json	  package.json    server.js

exit

you can also install curl here:

sudo apt-get install curl

curl -i localhost:49167

HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 28
ETag: W/"1c-3VUz2ekkyqpiEXzcqB5GN1p2ypQ"
Date: Mon, 14 Feb 2022 06:37:09 GMT
Connection: keep-alive
Keep-Alive: timeout=5

Hello world i am nodejs 

* Create a git repo and clone it on your vm

git clone <your-git-repo-url>

Do ls

go inside your repo folder

cd Nodejs/

cd ..

cp -R* nodeapp Nodejs

cd Nodejs/

git init

git commit -m "first"

git remote add origin <url of git repo>

git push -u orgin main #check your repo is main/master branch

Name:< your github user name>
password: <generate a github token and paste this> 

#In the upper-right corner of github page, click your profile photo, then click Settings.
In the left sidebar, click Developer settings.
In the left sidebar, click Personal access tokens.
Click Generate new token.
Give your token a descriptive name.

# create a jenkins job

nodejs-pipeline

#got to Source Code Management

choose git here

paste the Repository URL here

Edit the branch main/master

# Go to Build Triggers:

GitHub hook trigger for GITScm polling #for this you have to add webhook 

steps for adding webhook

Navigate to your GitHub repository and select Settings.
Select Add webhook under Webhooks.

Payload URL;
http://public-ip-of-vm/github-webhook/ 

Content type:

choose application/json

Which events would you like to trigger this webhook?

Just the push event.

and click on create webhook

# Go to Build Environment;

Delete workspace before build starts

Build

# Go to execute shell command:

pwd 
ls
sudo docker build . -t mddanish123/node-web-app
sudo docker rm --force nodeapp
sudo docker run --name nodeapp -p 49167:9080 -d mddanish123/node-web-app

Then go to the job and type Build

Go to the console output:

Console Output;

Started by user Md Danish
Running as SYSTEM
Building in workspace /var/lib/jenkins/workspace/Dockerize
[WS-CLEANUP] Deleting project workspace...
[WS-CLEANUP] Deferred wipeout is used...
[WS-CLEANUP] Done
The recommended git tool is: NONE
No credentials specified
Cloning the remote Git repository
Cloning repository https://github.com/Md-Danish-eng/dockerize.git
 > git init /var/lib/jenkins/workspace/Dockerize # timeout=10
Fetching upstream changes from https://github.com/Md-Danish-eng/dockerize.git
 > git --version # timeout=10
 > git --version # 'git version 2.25.1'
 > git fetch --tags --force --progress -- https://github.com/Md-Danish-eng/dockerize.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin.url https://github.com/Md-Danish-eng/dockerize.git # timeout=10
 > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
Avoid second fetch
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
Checking out Revision 6f2f0178d7cd4b5111bb3c47df7a503e55fcdb72 (refs/remotes/origin/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 6f2f0178d7cd4b5111bb3c47df7a503e55fcdb72 # timeout=10
Commit message: "Update server.js"
 > git rev-list --no-walk 6f2f0178d7cd4b5111bb3c47df7a503e55fcdb72 # timeout=10
[Dockerize] $ /bin/sh -xe /tmp/jenkins4796172036923287573.sh
+ pwd
/var/lib/jenkins/workspace/Dockerize
+ ls
Dockerfile
README.md
node_modules
package-lock.json
package.json
server.js
+ sudo docker build . -t mddanish123/node-web-app
Sending build context to Docker daemon    702kB

Step 1/7 : FROM node:16
 ---> 1e151315aa91
Step 2/7 : WORKDIR /app
 ---> Using cache
 ---> 4038435e47a1
Step 3/7 : COPY package*.json ./
 ---> Using cache
 ---> ba2ef25d67e2
Step 4/7 : RUN npm install
 ---> Using cache
 ---> faf0e76caffa
Step 5/7 : COPY . .
 ---> 58799fda0687
Step 6/7 : EXPOSE 9080
 ---> Running in 1fecaf422f09
Removing intermediate container 1fecaf422f09
 ---> e90b545ad744
Step 7/7 : CMD [ "node", "server.js" ]
 ---> Running in 8ccd9bc700a1
Removing intermediate container 8ccd9bc700a1
 ---> bf36a1ae658d
Successfully built bf36a1ae658d
Successfully tagged mddanish123/node-web-app:latest
+ sudo docker run -p 49167:9080 -d mddanish123/node-web-app
1d7441d4a41abde9ec0eb2daa542d061a0fd9020760a7e39b140f406aafd2693
Finished: SUCCESS

Now go to the browser and check by hit public-ip:49167

Hello world i am nodejs

Thanks!






