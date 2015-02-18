#!/bin/bash -x


add2pkgget()
{
for ball in * ; do rm -rf /tmp/jdk$$ ; mkdir -p /tmp/jdk$$ ; /usr/sfw/bin/gtar zxvf ${ball} -C /tmp/jdk$$ ; for i in /tmp/jdk$$/*/pkginfo ; do echo $i; echo next; ARCH=`grep "^ARCH=" ${i}|awk -F\= {'print $2'}` ;PKGNAME=`grep "^PKG=" ${i}|awk -F\= {'print $2'}` ; echo ${ARCH} ; echo next ;INST=`basename \`dirname ${i} \`` ; echo "${PKGNAME}" ; echo next  ; pkgtrans -s /tmp/jdk$$/  /unix_ops/osImage/SunOS/pkgs/${ARCH}/5.10/${PKGNAME}.${ARCH}.`__getepoc`.pkg ${PKGNAME}; done ; done

}

pkgs2dl=`wget http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html -O - |egrep '\.rpm|\.Z'|perl -p -e "s|^.*\"filepath\":||g"|sort -u|perl -p -e "s|\}.*$||g"|head -12`

for dl in `echo "${pkgs2dl}"` ; do
  dest=`basename ${dl}|perl -p -e "s|\"||g"`
  src=`echo "${dl}"|perl -p -e "s|\"||g"`
  wget --cookies=on --load-cookies=/unix_ops/cookies.txt --proxy=off --keep-session-cookies --no-check-certificate  ${src}  -O /tmp/${dest}
done



