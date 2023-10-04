#!/bin/bash

 sudo yum update -y 
    sudo yum install unzip wget httpd -y  
    sudo wget https://github.com/utrains/static-resume/archive/refs/heads/main.zip
    sudo unzip main.zip
    #sudo rm -rf /var/www/html/*
    sudo cp -r static-resume-main/* /var/www/html/  
    sudo systemctl start httpd
    sudo systemctl enable httpd 