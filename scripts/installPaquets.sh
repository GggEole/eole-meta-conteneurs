#!/bin/sh

if ! command -v wget 
then
	apt-eole install wget
fi
if ! command -v git 
then
	apt-eole install git
fi
if ! command -v make 
then
	apt-eole install make
fi
if ! command -v pip
then
	apt-eole install  python-pip
fi

if [ ! -d /usr/lib/python2.7/dist-packages/yaml ]
then
	apt install -y python-yaml
fi

if ! command -v docker
then
	wget -qO- https://get.docker.com/ | sh
	usermod -aG docker arun
	systemctl start docker
fi

if ! command -v docker-compose
then
	pip install docker-compose
fi

if [ ! -d /etc/systemd/system/docker.service.d ]
then
	mkdir -p /etc/systemd/system/docker.service.d
fi
apt-get install bridge-utils

#snap
if ! command -v snap
then
	apt install -y snapd
fi
if ! command -v snapcraft
then
	apt install -y snapcraft
fi

  
#vagrant
if [ ! -d /usr/lib/virtualbox ]
then
	apt install virtualbox virtualbox-dkms 
fi
if ! command -v vagrant
then
	apt install vagrant 
fi

apt autoremove -y
#lcx
