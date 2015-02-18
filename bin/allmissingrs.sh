#!/bin/bash -x


DATESTRING=`date +%m_%d_%Y_%H_%M_%S`
HOSTNAME=`/bin/hostname|awk -F. {'print $1'}`
CWD=`pwd`
PATCHBASE=`dirname $0`
FQPATCHBASE=`echo "${PATCHBASE}"|perl -p -e "s|^([^/]*)|${CWD}/\1|"`
MYRPTDIR="${FQPATCHBASE}/../summary"
##exit
find ${FQPATCHBASE}/../system/*/pca.patch.report -exec grep  "^[0-9].....-[0-9]." {} \;|awk -F, {'print $1'}|sort -u > "${MYRPTDIR}/allmissingrs.out"

