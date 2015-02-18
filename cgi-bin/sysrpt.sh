#!/bin/bash


echo "Content-type: text/plain"
echo ""

umask 0117

__getepoch()
{
sleep 1
perl -e 'print time(), "\n" '
}


olddoit()
{
set -x
env
SELF=`basename $0`
SCRATCHDIR="/tmp/$$_${SELF}_`__getepoch`"
rm -rf "${SCRATCHDIR}"
mkdir -p "${SCRATCHDIR}"
chmod 775 "${SCRATCHDIR}"

test "X${REMOTE_ADDR}" = "X" && exit
FQDN=`getent hosts ${REMOTE_ADDR}|awk {'print $2'}|head -1`
test "X${FQDN}" = "X" && exit
echo "${FQDN}"|grep "localhost" && FQDN=`hostname`
test "X${FQDN}" = "X" && exit
VALIDPATH=`echo "${QUERY_STRING}"|perl -n -e 'print if /^\/[\w,\/,\.,\*,\?,\-]+$/'`
test "X${VALIDPATH}" = "X" && exit
ITEMBASE=`basename ${VALIDPATH}`
umask

scp -i /etc/httpd/id_dsa -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=30 "system@${FQDN}:${VALIDPATH}" "${SCRATCHDIR}" && {
  DESTDIR="/unix_ops/system.INCOMING/${FQDN}/"
  mkdir -p "${DESTDIR}" || exit
  chmod -R 775 "${DESTDIR}"
  cp ${SCRATCHDIR}/* "${DESTDIR}"
  chmod -R 775 "${DESTDIR}"
  chmod -R 775 "${DESTDIR}/${ITEMBASE}"
  }

rm -rf "${SCRATCHDIR}"
}

doit()
{
set -x
env
SELF=`basename $0`
SCRATCHDIR="/tmp/$$_${SELF}_`__getepoch`"
rm -rf "${SCRATCHDIR}"
mkdir -p "${SCRATCHDIR}"
chmod 775 "${SCRATCHDIR}"

test "X${REMOTE_ADDR}" = "X" && exit
FQDN=`getent hosts ${REMOTE_ADDR}|awk {'print $2'}|head -1`
test "X${FQDN}" = "X" && exit
echo "${FQDN}"|grep "localhost" && FQDN=`hostname`
test "X${FQDN}" = "X" && exit
VALIDPATH=`echo "${QUERY_STRING}"|perl -n -e 'print if /^\/[\w,\/,\.,\*,\?,\-]+$/'`
test "X${VALIDPATH}" = "X" && exit
ITEMBASE=`basename ${VALIDPATH}`
umask

ssh -tt -i /etc/httpd/id_dsa -o PasswordAuthentication=no -o StrictHostKeyChecking=no  -o ConnectTimeout=30 system@${FQDN} "export PATH="${PATH}:/usr/local/bin" ; sudo cat "${VALIDPATH}"|perl -MMIME::Base64 -ne 'print encode_base64(\$_)' " > ${SCRATCHDIR}/${ITEMBASE} && {
##  dos2unix "${SCRATCHDIR}/${ITEMBASE}"
  DESTDIR="/unix_ops/system.INCOMING/${FQDN}/"
  DESTBASE=`dirname ${VALIDPATH}`
  mkdir -p "${DESTDIR}" ; chmod -R 775 "${DESTDIR}"
  mkdir -p "${DESTDIR}/${DESTBASE}" ; chmod -R 775 "${DESTDIR}/${DESTBASE}"
  mkdir -p "${DESTDIR}" || exit
  mkdir -p "${DESTDIR}/${DESTBASE}" || exit
  chmod -R 775 "${DESTDIR}"
  cat "${SCRATCHDIR}/${ITEMBASE}" |perl -MMIME::Base64 -ne 'print decode_base64($_)' > "${DESTDIR}/${DESTBASE}/${ITEMBASE}"
  chmod -R 775 "${DESTDIR}"
  chmod -R 775 "${DESTDIR}/${DESTBASE}"
  file -i "${DESTDIR}/${DESTBASE}/${ITEMBASE}"|grep -E "(^.*: text\/|^.*: message\/|^.*: application\/x-shellscript|^.*: application\/x-perl|^.*: application\/x-awk)" && {
    cat "${DESTDIR}/${DESTBASE}/${ITEMBASE}"
    }
  }

rm -rf "${SCRATCHDIR}"

}
set -x

doit >> /unix_ops/CGILOGS/fetch.log 2>&1

