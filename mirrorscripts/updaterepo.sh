#!/bin/bash -x

CWD="$(pwd)"
REPO="$(dirname $0)"
REPO=`echo "${REPO}"|perl -p -e "s|^([^/])|${CWD}/\1|"`

##exit
cd "${REPO}"
find . -name "*.rpm" \! -name "openscap*.rpm"|grep -i -v mysql57 > READ_PKGS_LIST
createrepo ${1} -v --pkglist READ_PKGS_LIST -s sha `pwd`

