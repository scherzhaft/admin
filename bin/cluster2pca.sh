#!/bin/bash -x


SELF=`basename $0`
##exit
CWD=`pwd`
test "X${*}" = "X" && exit 1
CLUSTERS=`echo "${*}"|perl -p -e "s| |\n|g"|sort -u|grep '.'|perl -p -e "s|^([^\/])|${CWD}/\1|g"`
PATCHBASE=`dirname $0`
PATCHBASE=/unix_ops/osImage/SunOS
FQPATCHBASE="${PATCHBASE}"
PATCHDIR="${FQPATCHBASE}/patches"
##exit
mkdir -p "${PATCHDIR}"



for cluster in `echo "${CLUSTERS}"` ; do
  PATCHES2LOAD=''
  PATCHPATHS=`unzip -l ${cluster} |awk {'print $NF'}|grep "Recommended"|grep "/[0-9].....-[0-9]./"|perl -p -e "s|(/[0-9].....-[0-9]./).*|\1|g"|sort -u`
  test "X${PATCHPATHS}" = "X" && continue
  PATCHES=`echo "${PATCHPATHS}"|perl -p -e "s|^.*/([0-9].....-[0-9].)/.*|\1|g"`
read test
  test "X${PATCHES}" = "X" && continue
  PATCHFILES=`echo "${PATCHES}"|perl -p -e "s|^(.*)|${PATCHDIR}/\1.zip|g"`
read test
  MISSINGPATCHES=`set +x ;(ls -d ${PATCHFILES} >/dev/null) 2>&1|perl -p -e "s|: No such file or directory||g"|perl -p -e "s|^ls: cannot access ||g"`
  echo "${MISSINGPATCHES}"|wc -l
read test
  test "X${MISSINGPATCHES}" = "X" && continue
  CLUSTERBASE=`echo "${PATCHPATHS}"|perl -p -e "s|/[0-9].....-[0-9]./.*||g"|sort -u|head -1`
  NEEDEDPATCHES=`echo "${MISSINGPATCHES}"|perl -p -e "s|^${PATCHDIR}/([0-9].....-[0-9].)\.zip$|${CLUSTERBASE}/\1/\*|g"`
  test "X${NEEDEDPATCHES}" = "X" && continue
  rm -rf "/tmp/${SELF}$$"
  mkdir -p "/tmp/${SELF}$$"
  unzip -o ${cluster} ${NEEDEDPATCHES} -d "/tmp/${SELF}$$"
  cd "/tmp/${SELF}$$/${CLUSTERBASE}" && PATCHES2LOAD=`ls -d *`
  test "X${PATCHES2LOAD}" != "X" && {
  for p in `echo "${PATCHES2LOAD}"` ; do
    zip -r "${PATCHDIR}/${p}.zip" ${p}
  done
}
  cd "${CWD}"
done


cd "${CWD}"
rm -rf "/tmp/${SELF}$$"

