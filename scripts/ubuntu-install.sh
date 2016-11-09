#!/usr/bin/env bash
# Script à lancer sur un Ubuntu ou dérivé

source vars

# Installation des paquets et dépots nécessaires
ksrv="hkp://p80.pool.sks-keyservers.net:80"
keys="58118E89F3A912897C070ADBF76221572C52609D"
repo="https://apt.dockerproject.org/repo"

apt-key adv --keyserver ${ksrv} --recv-keys ${keys}
echo "deb ${repo} ${distro} main" > /etc/apt/sources.list.d/docker.list
#apt-get update
apt-get install -y docker-engine python-pip sharutils python-yaml
pip install docker-compose

# Création du certificat
cd quickzephir
. make_cert.sh

# Récupération des images docker de la web-console et du ssh-tunnel
docker pull $DOCKER_USER/$DOCKER_WEBCONSOLE:$DOCKER_TAG
docker pull $DOCKER_USER/$DOCKER_SSHTUNNEL:$DOCKER_TAG

# Création d'une paire de clés ssh pour le serveur QuickZéphir
mkdir ssh
ssh-keygen -f ssh/id_rsa -N "" -q
chmod 600 ssh/id_rsa ssh/id_rsa.pub

# Peuplement du fichier ansible/hosts
# demande le mot de passe du compte zéphir déclaré dans ZEPHIR_LOGIN du fichier vars
cd ansible
python get_serveurs.py

cd ../..

echo "Fin de l'installation de QuickZéphir"
echo "Pensez à diffuser la clé publique (id_rsa.pub) générée pour quickzephir dans le dossier quickzephir/ssh vers les serveurs à administrer"
echo "Vous pourrez alors lancer le script 'quickzephir-start.sh'"
