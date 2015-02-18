#!/bin/bash
##set -x

sync() ##synchronize ops data with drive
{
OPSVOL=`awk {'print $1" "$2'} /etc/mtab |grep '/unix_ops '|awk {'print $2'}`
test "X${OPSVOL}" = "X" && exit
cd /unix_ops || exit

test -f /var/lock/subsys/xfr_sync  &&  {
  echo
  echo "##############################"
  echo "## sync already in progress ##"
  echo "##############################"
  echo
  exit
  }

test -f /var/lock/subsys/xfr_xport &&  {
  echo
  echo "################################"
  echo "## export already in progress ##"
  echo "################################"
  echo
  exit
  }

test -f /var/lock/subsys/xfr_xport_mail  && {
  xport
  echo "Export complete, you can safely un-plug the drive from foo" | mailx -r ${__SUDO_USER_MAIL} -s "Drive Export: Complete"  ${__SUDO_USER_MAIL}
  rm -f /var/lock/subsys/xfr_xport_mail
  exit
  }

echo
echo "###################"
echo "## starting sync ##"
echo "###################"
echo
touch /var/lock/subsys/xfr_sync

test -d /unix_ops/OUTGOING.nipr.git.clone/.git || {
  rm -rf /unix_ops/OUTGOING.nipr.git.clone
  git clone /unix_ops/master.git OUTGOING.nipr.git.clone
  }

##rm -f /unix_ops/nipr.master.checkout.tar.gz
cd OUTGOING.nipr.git.clone && git pull origin master  &&  {
  sleep 3
####  cd /unix_ops  && tar czpvf /unix_ops/nipr.master.checkout.tar.gz   OUTGOING.nipr.git.clone
  cd /unix_ops  
  }

sleep 3
####exit
cat > /dev/stdout  <<"__EOF__"|ssh -tt -i /etc/httpd/id_dsa -o PasswordAuthentication=no -o StrictHostKeyChecking=no  -o ConnectTimeout=30  system@foo ". /etc/default/SYSconstants ;set -x ;sudo /bin/bash -x ; exit  "

##best attempt to insure history is not saved
export BASHOPTS=checkwinsize:expand_aliases:extquote:force_fignore:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
export HISTFILE=/dev/null
export HISTFILESIZE=0
export HISTSIZE=0
export SHELLOPTS=braceexpand:emacs:hashall:interactive-comments:monitor

. /etc/default/SYSconstants
MOUNTED=`grep "^xfr" /etc/mnttab|awk {'print $1" "$2'}|grep "^xfr "`
test "X${?}" != "X0" && exit
XFRVOL=`echo "${MOUNTED}"|awk {'print $2'}`
test "X${XFRVOL}" = "X" && exit
OPSVOL=`awk {'print $1" "$2'} /etc/mnttab |grep '/unix_ops '|awk {'print $2'}`
test "X${OPSVOL}" = "X" && exit


cd ${OPSVOL} && rsync -av --delete --stats --exclude '.pcaLock*' --exclude '.nfs*' osImage SYScontrib OUTGOING.nipr.git.clone ${XFRVOL}
exit

__EOF__

rm -f /var/lock/subsys/xfr_sync
echo
echo "###################"
echo "## sync complete ##"
echo "###################"
echo

exit 

}


xport()  ##properly export/unmount the drive
{


test -f /var/lock/subsys/xfr_sync  &&  {
  touch /var/lock/subsys/xfr_xport_mail
  echo
  echo "#####################################################################################"
  echo "## there is a current sync in progress, i will email you once the export completes ##"
  echo "## see you soon                                                                    ##"
  echo "#####################################################################################"
  echo
  exit
  }

touch /var/lock/subsys/xfr_xport
echo
echo "#####################"
echo "## starting export ##"
echo "#####################"
echo

cat > /dev/stdout  <<"__EOF__"|ssh -tt -i /etc/httpd/id_dsa -o PasswordAuthentication=no -o StrictHostKeyChecking=no  -o ConnectTimeout=30  system@foo ". /etc/default/SYSconstants ;set -x ;sudo /bin/bash -x ; exit  "

##best attempt to insure history is not saved
export BASHOPTS=checkwinsize:expand_aliases:extquote:force_fignore:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
export HISTFILE=/dev/null
export HISTFILESIZE=0
export HISTSIZE=0
export SHELLOPTS=braceexpand:emacs:hashall:interactive-comments:monitor

. /etc/default/SYSconstants
MOUNTED=`grep "^xfr" /etc/mnttab|awk {'print $1" "$2'}|grep "^xfr "`
test "X${?}" != "X0" && exit
XFRPOOL=`echo "${MOUNTED}"|awk {'print $1'}`
test "X${XFRPOOL}" = "X" && exit
zpool export ${XFRPOOL}

exit

__EOF__

rm -f /var/lock/subsys/xfr_xport
echo
echo "#####################"
echo "## export complete ##"
echo "#####################"
echo

}

mport()  ##import the drive
{


cat > /dev/stdout  <<"__EOF__"|ssh -tt -i /etc/httpd/id_dsa -o PasswordAuthentication=no -o StrictHostKeyChecking=no  -o ConnectTimeout=30  system@foo ". /etc/default/SYSconstants ;set -x ;sudo /bin/bash -x ; exit  "

##best attempt to insure history is not saved
export BASHOPTS=checkwinsize:expand_aliases:extquote:force_fignore:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
export HISTFILE=/dev/null
export HISTFILESIZE=0
export HISTSIZE=0
export SHELLOPTS=braceexpand:emacs:hashall:interactive-comments:monitor

. /etc/default/SYSconstants
zpool import xfr

exit

__EOF__

echo
echo "#####################"
echo "## import complete ##"
echo "#####################"
echo


}


usage()  ##cmd usage message
{
/bin/echo
/bin/echo  "usage: ${SELF} sync     -   synchronize ops data with drive."
/bin/echo  "usage: ${SELF} xport    -   export/unmount drive, required before unplugging."
/bin/echo  "usage: ${SELF} mport    -   import/mount drive, required before syncing."
/bin/echo
}

##main

SELF=`/bin/basename $0`
ARGS="${*}"
test "X${ARGS}" != "Xsync" -a "X${ARGS}" != "Xxport" -a "X${ARGS}" != "Xmport" && {
  usage
  exit 1
  }


. /etc/default/SYSconstants

${ARGS}


