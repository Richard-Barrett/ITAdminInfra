#!/bin/bash
check=$(ceph -s | grep -i "slow requests")
echo $check
if [[ -n $check   ]];then
  echo "setting norecover flag"
  ceph osd set norecover
else
  echo "no slow requests"
  ceph osd unset norecover
fi
