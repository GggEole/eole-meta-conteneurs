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

function doDocker()
{
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

    		 echo "docker pull "$NOM_IMAGE""
    		 docker pull "$NOM_IMAGE"

             ID=$(docker ps -a -q --filter=name=$NAME)
             if [ -z "$ID" ]
             then
                 echo "docker images "
        		 docker images

        		 echo " sysctl -w net.ipv4.ip_forward=1"
    	    	 sysctl -w net.ipv4.ip_forward=1

	    		 echo "service docker start"
    	    	 service docker start

                 echo "docker run ${DKR_VOLS}  ${DKR_PORTS} $NOM_IMAGE"
        		 docker run -d ${DKR_VOLS} ${DKR_PORTS} --name "$NAME" "$NOM_IMAGE"
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
             doDocker
    	  	 ;;

        "docker-git")

            if [ -n "$REPOSITORY" ]
            then
                cd /home
                if [ ! -d $NAME ]
                then
                    DOSSIER=$(mktemp -d)
                    mkdir -p $DOSSIER
                    cd $DOSSIER || exit 1
                    git clone "$REPOSITORY"
                    mv ./* /home/$NAME/
                else
                    cd $NAME
                    git pull
                fi
                docker build .
            else
                cd /home/$NAME
            fi
            doDocker
            ;;

        "snap")
        	echo "snap list"
        	snap list

        	echo "snap install $URL"
        	snap install "$URL"
        	;;

        "snap-craft")
            if [ -n "$REPOSITORY" ]
            then
                cd /home
                if [ ! -d $NAME ]
                then
                    DOSSIER=$(mktemp -d)
                    mkdir -p $DOSSIER
                    cd $DOSSIER || exit 1
                    git clone "$REPOSITORY"
                    mv ./* /home/$NAME/
                else
                    cd $NAME
                    git pull
                fi
                docker build .
            else
                cd /home/$NAME
            fi

            ;;

        "vagrant")
            if [ -n "$REPOSITORY" ]
            then
                cd /home
                if [ ! -d $NAME ]
                then
                    DOSSIER=$(mktemp -d)
                    echo "$DOSSIER"
                    mkdir -p $DOSSIER
                    cd $DOSSIER || exit 1
                    git clone "$REPOSITORY"
                    set -x
                    /bin/mv * /home/$NAME
                else
                    cd $NAME
                    git pull
                fi
                cd /home/$NAME
                VBoxManage --version
                vagrant up &
            else
                cd /home/$NAME
                vagrant init "$URL"
                vagrant up &
            fi

            ;;

        "qemu")
            ;;

        "jboss")
            ;;

        *)
            EchoRouge "Type technologie inconnue : '${TYPE}'"
            exit 1
            ;;
    esac

}

function doPostTemplateInit()
{
    mkdir -p /etc/nginx/conteneur.d
    cat >/etc/nginx/sites-available/conteneur.conf <<EOF
server {
  listen 80;
    server_name eolebase.ac-test.lan;
    include /etc/nginx/conteneur.d/*.conf;
  }
EOF
    rm -f /etc/nginx/sites-enabled/conteneur.conf
    ln -s /etc/nginx/sites-available/conteneur.conf /etc/nginx/sites-enabled/
}

function doPostTemplate()
{
    rm -f /etc/nginx/site-available/conteneur${1}.conf
    rm -f /etc/nginx/site-enabled/conteneur${1}.conf
	NAME=$(CreoleGet "conteneur${1}_name" "")
	if [ -z "$NAME" ]
	then
		echo "conteneur : $1 non actif"
        rm -f /etc/nginx/conteneur.d/conteneur${1}.conf
		return 0
    fi
	echo "conteneur : $1"

	TYPE=$(CreoleGet "conteneur${1}_type")
	SERVER_NAME=$(CreoleGet "ssl_server_name")
	declare -a PORT_OUT
	PORT_OUT=($(CreoleGet "conteneur${1}_port_out"))
    if [ -z "${PORT_OUT[0]}" ]
    then
		echo "conteneur : $1 pas de port"
        rm -f /etc/nginx/conteneur.d/conteneur${1}.conf
		return 0
    fi

    cat >/etc/nginx/conteneur.d/conteneur${1}.conf <<EOF
location /$NAME {
    proxy_set_header        Host \$host:\$server_port;
    proxy_set_header        X-Real-IP \$remote_addr;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto \$scheme;
    proxy_pass              http://127.0.0.1:${PORT_OUT[0]};
}
EOF
}
