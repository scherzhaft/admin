#!/bin/bash -x


SELF="$(basename $0)"
MYDIR="$(dirname $0)"
TARGET='/unix_ops/osImage/RH'
OS='redhat'

set -x
VER="$(rpm -qa  --queryformat '%{NAME}|%{VERSION}\n'|grep "^redhat-release"|grep -v notes|awk -F\| {'print $2'})"
  
case "${VER}" in 
  5Server)
    CHANNEL='rhel-x86_64-server-5'
    EXTRA_ARGS=''
  ;;
  
  6Server)
    CHANNEL='rhel-x86_64-server-6'
    EXTRA_ARGS=' --workers=6 -s sha '
  ;;
  *)
    echo "...unknown release...exiting"
    exit 1
esac
  
doit ()
{
set -x
    
/usr/bin/lsb_release -i|grep -i "${OS}" || {
  echo "...unknown os...exiting"
  exit 1
  }
  

/usr/bin/lsb_release -i|grep -i "${OS}" && {
  
  if [ -f /var/lock/subsys/mirror_${OS}_${VER}_updates ]; then
    echo "Channel busy downloading"
    exit 0
  fi

  cd "${TARGET}" && {
    test -f /etc/yum/pluginconf.d/rhnplugin.conf && perl -p -i -e "s|^enabled.*$|enabled=1|g" /etc/yum/pluginconf.d/rhnplugin.conf
    touch /var/lock/subsys/mirror_${OS}_${VER}_updates
    reposync -p `pwd` --repoid="${CHANNEL}" -l
    cd "${CHANNEL}"
    rm READ_PKGS_LIST
    ln -sf getPackage updates
    find `ls -d */|grep -v getPackage` \! -type d -name *.rpm > READ_PKGS_LIST
    createrepo  -v  --pkglist READ_PKGS_LIST ${EXTRA_ARGS} `pwd`  ###2>&1 > createrepo.out
    cd updates && createrepo  -v  ${EXTRA_ARGS} `pwd`  ###2>&1 > createrepo.out
    /bin/rm -f /var/lock/subsys/mirror_${OS}_${VER}_updates
    }
  }

}


####doit > "${MYDIR}/../mirrorlogs/${SELF}_${CHANNEL}.log" 2>&1
test "X${1}" != "X" && doit  2>&1 | tee "${MYDIR}/../mirrorlogs/${SELF}_${CHANNEL}.log"
test "X${1}" = "X" && echo "usage:  ${SELF} doit"
