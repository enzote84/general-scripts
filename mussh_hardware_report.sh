#!/bin/bash
#
# Reporte de hardware con mussh
#

HOSTLIST=$(cat $1)
SSHPASSFILE=$2

if [[ ! -z $2 ]]; then
echo "Copy SSH Key to hosts:"
for host in ${HOSTLIST}
do
  sshpass -f${SSHPASSFILE} ssh-copy-id -o "StrictHostKeyChecking no" ${host}
done
fi

echo -e "\tHOST:\t\tRAM(GB)\tDISK(GB)"

TOTRAM="0.0"
TOTDSK="0.0"

for host in ${HOSTLIST}
do

  USR=$(echo ${host} | cut -d'@' -f1)
  HST=$(echo ${host} | cut -d'@' -f2)

  RAM=$(mussh -h ${host} -c "free -m" | grep "Mem:" | awk '{print $3 / 1024;}')
  if [[ ! -z ${RAM} ]]; then
    TOTRAM=$(echo "${TOTRAM} + (${RAM})" | bc)
  fi

  DISK=$(mussh -h ${host} -c "df -k" | grep -v Filesystems | awk 'BEGIN{sum=0}{sum=sum + $3;}END{print sum/1024/1024;}')
  if [[ ! -z ${DISK} ]]; then
    TOTDSK=$(echo "${TOTDSK} + ${DISK}" | bc)  
  fi
  
  echo -e "${HST}:\t${RAM}\t${DISK}"

done

echo -e "TOTAL:\t${TOTRAM}\t${TOTDSK}"

