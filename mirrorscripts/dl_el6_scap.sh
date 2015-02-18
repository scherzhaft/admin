#!/bin/bash -x


CWD=`pwd`
TARGET='/unix_ops/osImage/SYScontrib/Linux/ARCHIVES'
SITE='people.redhat.com/swells/scap-security-guide/RHEL6/dist/content/'
mkdir -p /tmp/$$

if [ -d "${TARGET}" ] ; then
    cd "/tmp/$$" && {
        wget -t 7 -w 5 --waitretry=14 --random-wait --exclude-directories="icons,${OS}/${VER}/*/i386,${OS}/${VER}/*/*/drpms" -np -nd -nH --reject="*.html*" --mirror "http://${SITE}"
        test -f "${TARGET}/u_redhat_6_stig_benchmark.zip" && zip -f "${TARGET}/u_redhat_6_stig_benchmark.zip" *
        test -f "${TARGET}/u_redhat_6_stig_benchmark.zip" || zip  "${TARGET}/u_redhat_6_stig_benchmark.zip" *
    }
else
    echo "Target directory ${TARGET} not present."
fi

cd "${CWD}"
rm -rf  /tmp/$$




