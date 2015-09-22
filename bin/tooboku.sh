#!/bin/bash -x

CWD=`pwd`
test "X${*}" = "X" && exit
ARGS="${*}"

OPERANDFILE=`echo "${ARGS}"|awk {'print $NF'}`
CMD=`echo "${ARGS}"|perl -p -e "s|${OPERANDFILE}$||g"`
EIGHTBALL=`cat ${OPERANDFILE}`


test "X${EIGHTBALL}" != "X" && {

  sleep 3

  EIGHTBALLINITIALTOTAL=`echo "${EIGHTBALL}"|wc -l|awk {'print $1'}|egrep  "^[0-9]+$"`
  test "X${EIGHTBALLINITIALTOTAL}" = "X" && exit 55

  EIGHTBALLHEADHALF="${EIGHTBALL}"
  EIGHTBALLTOTAL="${EIGHTBALLINITIALTOTAL}"
  EIGHTBALLHALF=`expr  "${EIGHTBALLTOTAL}" \/ 2`

  while : ; do
    cd /tmp
    TOOBOKU=`set +x ;(ls -d ${EIGHTBALLHEADHALF} >/dev/null) 2>&1`
    ####TOOBOKU="$(ls -d ${EIGHTBALLHEADHALF} 2>&1)"
    ##read foooo
    echo "${TOOBOKU}"|perl -p -e "s|\s+| |g"|grep -i "list too long "  >/dev/null
    ALABAMABLACKSNAKE="$?"
      test "X${ALABAMABLACKSNAKE}" = "X1"  &&  {
    ##read foooo
        EIGHTBALLSTEP="${EIGHTBALLINITIALTOTAL}"
        test "X${EIGHTBALLSTEP}" = "X" && exit 66
        test "X${EIGHTBALLTOTAL}" != "X${EIGHTBALLINITIALTOTAL}"  &&  EIGHTBALLSTEP="${EIGHTBALLHALF}"
        test "${EIGHTBALLSTEP}" -le 4999  &&  break
        test "${EIGHTBALLSTEP}" -gt 4999  &&  {
          EIGHTBALLSTEP=`expr "${EIGHTBALLSTEP}" \/ 2`
          test "X${EIGHTBALLSTEP}" = "X" && exit 72
          echo
          echo "${EIGHTBALLSTEP}"
          echo
          break
          }
        }
        
      test "X${ALABAMABLACKSNAKE}" = "X0"  &&  {
        EIGHTBALLTOTAL=`echo "${EIGHTBALLHEADHALF}"|wc -l|awk {'print $1'}`
        EIGHTBALLHALF=`expr  "${EIGHTBALLTOTAL}" \/ 2`
        EIGHTBALLHEADHALF=`echo "${EIGHTBALLHEADHALF}"|head -"${EIGHTBALLHALF}"`
        }
    done
  
  CB="${EIGHTBALLINITIALTOTAL}"
##  echo "${EIGHTBALLSTEP}"
##  echo "${EIGHTBALLTOTAL}"
##  echo "${EIGHTBALLHALF}"
##  ##echo "${EIGHTBALLHEADHALF}"

######exit
  EIGHTBALLSTATUS=''
  while : ; do
    ##exit $?
    cd "${CWD}"
    test "X${EIGHTBALLINITIALTOTAL}" = "X${EIGHTBALLSTEP}"  &&  {
      ${CMD}  ${EIGHTBALL}
      EIGHTBALLSTATUS="$?"
      cd "${CWD}"
      sleep 2
      break
      }

    cd "${CWD}"
    JUSTTHETIP=`echo "${EIGHTBALL}"|tail -"${CB}"|head -"${EIGHTBALLSTEP}"`
    test "X${JUSTTHETIP}"  != "X"  &&  {
      ${CMD}  ${JUSTTHETIP}
      EIGHTBALLSTATUS="${EIGHTBALLSTATUS}
$?"
      }

    cd "${CWD}"
    CB=`expr  ${CB} - ${EIGHTBALLSTEP}`
    echo "${CB}"|grep -- "^-"  &&  break 
    test "X${CB}" = "X0"  &&  break
    sleep 2
    done


cd "${CWD}"
FINALSTATUS=`echo "${EIGHTBALLSTATUS}"|grep -v "^0$"`

test "X${FINALSTATUS}" != "X" &&  exit 1

exit 0

}

exit 1

