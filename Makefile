################################
# Makefile pour eole-ad
################################

SOURCE=eole-gg
VERSION=2.6
EOLE_VERSION=2.6
EOLE_RELEASE=2.6.0
PKGAPPS=non
#FLASK_MODULE=<APPLICATION>

################################
# Début de zone à ne pas éditer
################################

include eole.mk
include apps.mk

################################
# Fin de zone à ne pas éditer
################################

# Makefile rules dedicated to application
# if exists
ifneq (, $(strip $(wildcard $(SOURCE).mk)))
include $(SOURCE).mk
endif
