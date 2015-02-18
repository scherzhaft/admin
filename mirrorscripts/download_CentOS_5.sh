#!/bin/bash -x
TARGET='/unix_ops/osImage'
OS='centos'
VER='5.9'
VER='5'
SITE='centos.servint.com'

if [ -f /var/lock/subsys/mirror_centos_${VER}_updates ]; then
    echo "Updates via wget already running."
    exit 0
fi
if [ -d "${TARGET}" ] ; then
    touch /var/lock/subsys/mirror_centos_${VER}_updates
    cd "${TARGET}" && mkdir -p "${TARGET}/../mirrorlogs" && wget -t 7 -w 5 --waitretry=14 --random-wait --exclude-directories="icons,${OS}/${VER}/*/i386,${OS}/${VER}/*/*/drpms" -np -nH --reject="*.html*" --mirror "http://${SITE}/${OS}/${VER}/" -o "${TARGET}/../mirrorlogs/${OS}.${VER}.mirror.log"

####    rsync  -avSHP --delete --exclude "local*" --exclude "isos" --exclude "*/i386" ${SITE}::${OS}/${VER}/ "${TARGET}/${OS}/${VER}"
    /bin/rm -f /var/lock/subsys/mirror_centos_${VER}_updates
else
    echo "Target directory ${TARGET} not present."
fi


##time wget --exclude-directories="icons,osImage/centos/6" --reject="*.html*" --mirror http://localhost/osImage/centos/6.4/ -o ./centosmirror.log

##wget -t 7 -w 5 --waitretry=14 --random-wait --exclude-directories="icons,centos/6.4/*/i386,centos/6.4/*/*/drpms" -np -nH --reject="*.html*" --mirror http://centos.servint.com/centos/6.4/ -o centosmirror.log


