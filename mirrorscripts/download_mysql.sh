#!/bin/bash -x


SELF="$(basename $0)"
MYDIR="$(dirname $0)"
TARGET='/unix_ops/SYScontrib/Linux/repos'


doit ()
{
set -x
    
  
if [ -f /var/lock/subsys/mirror_mysql_updates ]; then
  echo "Channel busy downloading"
  exit 0
fi

cd "${TARGET}" && {
  MYSQLREPOD=`ls -d /etc/yum.repos.d/mysql-community* 2>/dev/null`
  test "X${MYSQLREPOD}" != "X" && perl -p -i -e "s|^enabled=*.*$|enabled=1|g" ${MYSQLREPOD}
  touch /var/lock/subsys/mirror_mysql_updates
  CHANNELS=`cat ${MYSQLREPOD}|grep  "^\["|perl -p -e "s|^\[([^\]]+)]*$|\1|g"|sort -u`
  test "X${CHANNELS}" != "X" && {
    CHANNELARGS=`echo "${CHANNELS}"|perl -p -e "s|^|--repoid=\"|g"|perl -p -e "s|\n|\" |g"`
    eval "reposync -p `pwd` "${CHANNELARGS}""
    cd .. && ./updaterepo.sh
    cd ${TARGET}
    perl -p -i -e "s|^enabled=*.*$|enabled=0|g" ${MYSQLREPOD}
    /bin/rm -f /var/lock/subsys/mirror_mysql_updates
    }
  }
}

doit  2>&1 | tee "${MYDIR}/../mirrorlogs/${SELF}_${CHANNEL}.log"


