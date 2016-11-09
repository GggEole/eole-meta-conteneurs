#!/bin/bash
# -*- shell-script -*-

# shellchek disable=SC1091
. /usr/lib/eole/ihm.sh

#
# genere une clef SSH si elle manque
#
function check_ssh_key()
{
    [ ! -d /root/.ssh ] && mkdir -p /root/.ssh

    if [ ! -f /root/.ssh/id_rsa ]
    then
        echo "Generation de la clef SSH pour les echanges entre DC"
        ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
    fi
}

function doPostService()
{
	NAME=$(CreoleGet "conteneur${1}_name" "")
	if [ -z "$NAME" ]
	then
		echo "conteneur : $1 non actif"
		return 0
    fi
	echo "conteneur : $1"
	TYPE=$(CreoleGet "conteneur${1}_type")
	URL=$(CreoleGet "conteneur${1}_url")
	TAG=$(CreoleGet "conteneur${1}_tag")
	REPOSITORY=$(CreoleGet "conteneur${1}_repository")
	declare -a MOUNTPOINT_IN
	MOUNTPOINT_IN=($(CreoleGet "conteneur${1}_mountpoint_in"))
	declare -a MOUNTPOINT_OUT
	MOUNTPOINT_OUT=($(CreoleGet "conteneur${1}_mountpoint_out"))
	declare -a PORT_IN
	PORT_IN=($(CreoleGet "conteneur${1}_port_in"))
	declare -a PORT_OUT
	PORT_OUT=($(CreoleGet "conteneur${1}_port_out"))
	
	case "${TYPE}" in
    	"docker")
    		 DKR_PORTS=""
    		 idx=0
    		 for i in ${PORT_IN[@]}; 
			 do
			 	 DKR_PORTS="$DKR_PORTS -p $i:${PORT_OUT[$idx]} "
				 idx=$(( $idx + 1 ))
			 done
	
    		 DKR_VOLS=""
    		 idx=0
    		 for i in ${MOUNTPOINT_IN[@]}; 
			 do
			 	 mkdir -p "${MOUNTPOINT_OUT[$idx]}"
			 	 DKR_VOLS="$DKR_VOLS -v $i:${MOUNTPOINT_OUT[$idx]} "
				 idx=$(( $idx + 1 ))
			 done
	
			 if [ -z "$TAG" ]
			 then
    		     NOM_IMAGE="$URL"
    		 else
    		     NOM_IMAGE="$URL:$TAG" 
    		 fi

			 echo "service docker start"
    		 service docker start

    		 echo "docker pull "$NOM_IMAGE""
    		 docker pull "$NOM_IMAGE" 
    		 
    		 echo "docker images "
    		 docker images
    		 
    		 echo " sysctl -w net.ipv4.ip_forward=1"
    		 sysctl -w net.ipv4.ip_forward=1
    		 
    		 echo "docker run ${DKR_VOLS}  ${DKR_PORTS} $NOM_IMAGE" 
    		 docker run -d ${DKR_VOLS} ${DKR_PORTS} "$NOM_IMAGE"
    	  	 ;;
    	  	
        "docker-git")
        	 
             ;;

        "snap")
        	echo "snap list"
        	snap list
        	
        	echo "snap install $URL"
        	snap install "$URL"
        	;;

        "snap-craft")
            ;;

        "vagrant")
            ;;

        "qemu")
            ;;

        *)
            EchoRouge "Type technologie inconnue : '${TYPE}'"
            exit 1
            ;;
    esac
    
    ln -s /etc/nginx/sites-available/conteneur${1}.conf "$NAME"
    
}

function doPostTemplate()
{
	NAME=$(CreoleGet "conteneur${1}_name" "")
	if [ -z "$NAME" ]
	then
		echo "conteneur : $1 non actif"
		return 0
    fi
	echo "conteneur : $1"
	
	TYPE=$(CreoleGet "conteneur${1}_type")
	SERVER_NAME=$(CreoleGet "ssl_server_name")
	
    cat >/etc/nginx/sites-available/conteneur${1}.conf <<EOF
upstream $NAME {
  server 127.0.0.1:8080 fail_timeout=0;
}

server {
  listen 80;
  server_name $SERVER_NAME;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name $SERVER_NAME;

  ssl_certificate /etc/nginx/ssl/server.crt;
  ssl_certificate_key /etc/nginx/ssl/server.key;

  location /%%conteneur1_name {
    proxy_set_header        Host $host:$server_port;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_redirect 			http:// https://;
    proxy_pass              http://$NAME;
  }
}
EOF

}