#!/bin/bash -x



doit()
{
set -x
ARG1="${1}"
SELF=`basename $0`
##test "X${ARG1}" = "X" && ARG1='/'

GITFILE=`echo "${ARG1}"|perl -p -e "s|^/*||"|perl -p -e "s|//*|/|g"`
GITDIR=`dirname ${GITFILE}`
test "X${GITDIR}" = "X." && GITDIR=''
GITBAK=`basename ${GITDIR}`

cd /unix_ops/kickstart || exit 2
GITOUT=`git show HEAD:${GITFILE} 2>/dev/null| tee`
echo "${GITOUT}"|grep "^tree HEAD:" >/dev/null || {
echo "Content-type: text/plain"
echo ""
git show HEAD:${GITFILE} 2>/dev/null| tee
exit 0
}


GITOUT=`echo "${GITOUT}"|grep -v "^tree HEAD:"`
for i in `echo "${GITOUT}"` ; do
  GITHREF=`echo "${SELF}?${GITFILE}/${i}"|perl -p -e "s|//|/|g"`
  test "X${GITTABLE}" = "X" && GITTABLE=`echo "<tr><td valign="top"><img src="/icons/back.gif" alt="[   ]"></td><td><a href="${SELF}?${GITDIR}">..</a></td></tr>"`
  GITTABLE=`echo "${GITTABLE}
<tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="${GITHREF}">${i}</a></td></tr>"`
done

echo "Content-type: text/html"
echo ""
echo "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>Index of /${GITFILE}</title>
 </head>
 <body>
<h1>Index of /${GITFILE}</h1>
<table>
${GITTABLE}
</table>
</body></html>"

}

doit $1 ## 2>>/tmp/ks.log

####<tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="${SELF}/${GITFILE}">${GITFILE}</a></td></tr>
