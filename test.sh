#!/bin/bash
source_dir="/home/ubuntu/github-action-test"
cd $source_dir
git clone https://github.com/Md-Danish-eng/Deploy-sample-nodejs-app-on-ec2-instance-and-automate-through-Jenkins.git github-action
cd github-action
sudo docker build -t action .
sudo docker rm -f bloon 
sudo docker run -dit --name bloon -p 9080:9080 action
