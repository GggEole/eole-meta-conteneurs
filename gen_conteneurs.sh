#!/bin/bash -x 

function copie_conteneur()
{
	sed -e "s/conteneur1/conteneur$1/" -e "s/Conteneur-1/Conteneur-$1/" <dicos/25_conteneur1.xml >dicos/25_conteneur$1.xml
	#sed -e "s/conteneur1/conteneur$1/" -e "s/Conteneur-1/Conteneur-$1/" <tmpl/conteneur1.conf >tmpl/conteneur$1.conf
}

copie_conteneur 2
copie_conteneur 3
copie_conteneur 4
copie_conteneur 5