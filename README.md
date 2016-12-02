====================
eole-meta-conteneurs
====================

Atelier Devops/EOLE : Transformation eolebase pour gérer plusieurs technologie de conteneurs

.. sectnum::
.. contents::

Objectif de l'atelier
=====================

- Tester l'utilisation d'un outil de Devops (docker) pour spécialiser une application

- Voir comment industrialiser la mise en oeuvre de cette spécialisation 

Technologies
++++++++++++

- Docker : 

Docker permet d'embarquer une application dans un container virtuel qui pourra s'exécuter sur n'importe quel serveur. 
C'est une technologie qui a pour but de faciliter les déploiements d'application, et la gestion du dimensionnement de 
l'infrastructure sous-jacente. Un container est bootable en quelques secondes

Il existe un dépot https://hub.docker.com/ sur lequel nous pouvons trouver  plus de 460 000 images de container 
(avec Ubuntu, WordPress, MySQL, NodeJS...), cet espace est aussi intégré à GitHub.

- LXC :

Le container fait en effet directement appel à l'OS de sa machine hôte pour réaliser ses appels système et exécuter ses applications
Le container n'embarque pas d'OS, à la différence de la machine virtuelle, il est par conséquent beaucoup plus léger que cette dernière. Il n'a pas besoin d'activer un second système pour exécuter ses applications. Cela se traduit par un lancement beaucoup plus rapide, mais aussi par la capacité à migrer plus facilement un container d'une machine physique à l'autre, du fait de son faible poids. "Typiquement, un container nu représentera que quelques Mo"

- Qemu/KVM : 

Il s'agit de la technologie de virtualisation traditionnelle sur Linux. Elle permet, via un hyperviseur, de simuler 
une ou plusieurs machines physiques, et les exécuter sous forme de machines virtuelles (VM) sur un serveur machine. 
Ces VM intègrent elles-mêmes un OS sur lequel les applications qu'elles contiennent sont exécutées
Typiquement, une machine virtuelle pourra peser plusieurs Go

- Vagrant : 

TODO 

Réalisations
=====================

Création d'un projet Docker
+++++++++++++++++++++++++++

pour tester l'utilsiation de Docker, nous avons créer un projet 'poc-roland' (hébergé dans https://github.com/GggEole/poc-roland).
L'idée est de créer une image Docker en spécialisant l'outil Tomcat avec notre application "roro.war"

.. code-block:: ruby

   FROM tomcat:8.5.6-jre8
   COPY roro.war $CATALINA_HOME/webapps/
   CMD ["catalina.sh", "run"]

ou

.. code-block:: ruby

   FROM eolebase:2.6.0
   COPY config.eole /etc/eole/config.eol
   CMD ["python", ""]

Eolisation de conteneurs
++++++++++++++++++++++++

Il s'agit de créer les dicos et template EOLE pour gérer plusieurs conteneurs, et de proposer un moyen d'accès à chacun des ces conteneurs.

- Création des dicos
- Création des templates
- Mise au point du script d'instanciation
- Configuration de Nginx

- Création des dicos

Nous allons implémenter plusieurs dicos : 1 dico global et autant de dicos que de conteneur voulu.

dico global : "10_conteneur"
    fichier de varaible : /etc/eole/conteneur-vars.conf
    variable 'nombre_conteneur' : Nombre de conteneur à activer
    mécanique d'activation des familles 'Conteneur-X'
     
dico conteneur : "25_conteneurX"
     variable 'conteneur1_name' :
        Nom du conteneur, mais aussi le nom de la web apps présenté sur le module
        ex: si 'rocketchat', alors l'acces se fera par http://<module>/rocketchat ou par https://<module>/rocketchat
        
     variable 'conteneur1_type'           : Type de technologie
        il s'agit d'une liste des différentes technologie pouvant être utilisées
        ex: docker, docker+git, snap, snapcraft, vagrant, lxc 
        
     variable 'conteneur1_url'            : Url du conteneur
        c'est le nom publié de l'image
         
     variable 'conteneur1_tag'            : Tag de version du conteneur
        c'est l'identifiant de version de l'image.
        Dans le cas d'un dépot Git, il s'agit du tag du source 
        
     variable 'conteneur1_repository'     : Url du repository
        Il s'agit de l'URL du dépot ou l'on trouve l'image 'conteneur1_url'
          
     variable 'conteneur1_mountpoint_in'  : Volumes partagés dans le conteneur
     variable 'conteneur1_mountpoint_out' : Volumes partagés par le module
     variable 'conteneur1_port_in'        : Ports IP exposés dans le conteneur
     variable 'conteneur1_port_out'       : Ports IP exposés par le module
    
