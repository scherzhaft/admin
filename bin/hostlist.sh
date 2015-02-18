#!/bin/bash -x

GITREPO='/unix_ops/master.git'
test "X${GITREPO}" = "X" && exit 3
cd "${GITREPO}" || exit 4

sudo git show "master:system/"|grep '.'|grep -v "tree master:system/"|perl -p -e "s|\/$||g"

