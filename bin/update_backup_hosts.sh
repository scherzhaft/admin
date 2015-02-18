#!/bin/bash

doit()
{
##set -x
DAY=`perl -MPOSIX  -e '$datestring = strftime "%w", localtime; printf("$datestring\n");'` ;  test "X${DAY}" = "X" && exit 3
SELF=`basename $0` ;  test "X${SELF}" = "X" && exit 4


. /etc/default/SYSconstants || exit 3
DNSDOMAIN="$__DNSDOMAIN"

for i in {1..255} ; do host foo.foo.foo.${i} >/dev/null 2>&1 && host foo.foo.foo.${i}|perl -p -e "s|\n|${DNSDOMAIN}.\n|g"|perl -p -e "s|.${DNSDOMAIN}\.${DNSDOMAIN}\.|.${DNSDOMAIN}.|g"; done |perl -p -e "s|^([^\.]+)\.([^\.]+)\.([^\.]+)\.([^\.]+)(.*$)|\4.\3.99.\1\5|g"|perl -p -e "s|\.$||g"|awk {'print $1" b_"$NF" b_"$NF'}|perl -p -e "s|\.in-addr\.arpa||g"|perl -p -e "s|\.${DNSDOMAIN}$||g"|/usr/sfw/bin/ggrep -v -F "${__MYIPLIST}"|/usr/sfw/bin/ggrep -v  "${__HOSTNAME}"|/usr/sfw/bin/ggrep -v  "${__HOSTSHORT}" 


}
##set -x
DAY=`perl -MPOSIX  -e '$datestring = strftime "%w", localtime; printf("$datestring\n");'` ;  test "X${DAY}" = "X" && exit 3
SELF=`basename $0` ;  test "X${SELF}" = "X" && exit 4

rm -rf /tmp/${SELF}.$$
mkdir -p /tmp/${SELF}.$$

doit 2>/dev/null >/tmp/${SELF}.$$/hosts.update
cat /etc/hosts /etc/inet/hosts|sort -u > /tmp/${SELF}.$$/hosts

test -s /tmp/${SELF}.$$/hosts || exit $?
test -s /tmp/${SELF}.$$/hosts.update || exit $?
cp /etc/inet/hosts /etc/inet/hosts.${DAY} || exit $?

cat /tmp/${SELF}.$$/hosts /tmp/${SELF}.$$/hosts.update | sort -u > /etc/inet/hosts
ln -sf /etc/inet/hosts /etc/hosts

rm -rf /tmp/${SELF}.$$

