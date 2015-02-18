#!/bin/bash -x
TARGET='/unix_ops/SYScontrib/Linux'
OS='epel-5'
SOFTWARE='openscap'
SITE="repos.fedorapeople.org/repos/git${SOFTWARE}"

if [ -f /var/lock/subsys/mirror_${OS}_${SOFTWARE}_updates ]; then
    echo "Updates via wget already running."
    exit 0
fi
if [ -d "${TARGET}" ] ; then
    touch /var/lock/subsys/mirror_${OS}_${SOFTWARE}_updates
    cd "${TARGET}" && mkdir -p "${TARGET}/../../mirrorlogs" && wget -t 7 -w 5 --waitretry=14 --random-wait --exclude-directories="icons,*/*/*/*/*/repodata" -np -nH --reject="*.html*" --mirror "http://${SITE}/${SOFTWARE}/${OS}/" -o "${TARGET}/../../mirrorlogs/${OS}.${SOFTWARE}.mirror.log"
    find . -name "*.rpm" \! -name "openscap*.rpm" > READ_PKGS_LIST
    createrepo -v --pkglist READ_PKGS_LIST -s sha `pwd`
    /bin/rm -f /var/lock/subsys/mirror_${OS}_${SOFTWARE}_updates
else
    echo "Target directory ${TARGET} not present."
fi





