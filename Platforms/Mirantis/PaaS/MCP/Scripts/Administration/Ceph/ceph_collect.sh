#!/bin/bash
echo "Collecting Ceph cluster data."
echo "This script must be run on a monitor node."

if [ "$CUSTOMER" == '' ]; then CUSTOMER="default"; fi
if [ "$CLUSTERNAME" == '' ]; then CLUSTERNAME="cluster"; fi

if [ "$#" -lt 2 ]; then echo "Using customer \"$CUSTOMER\" and cluster name \"$CLUSTERNAME\". These values can be modified by seting the \$CUSTOMER and \$CLUSTERNAME shell variables\nor calling the script with $0 <CUSTOMER> <CLUSTERNAME>\n"; else CUSTOMER=$1; CLUSTERNAME=$2; fi

DATE=`date "+%Y-%m-%d"`
DIRNAME="CephCollectData.$CUSTOMER.$CLUSTERNAME.$DATE"
ARCHNAME=$DIRNAME".tar.bz2"
mkdir $DIRNAME
cd $DIRNAME

echo "Collecting CRUSH map"
ceph osd getcrushmap -o crush.bin
crushtool -d crush.bin -o crushmap.txt
crushtool -i crush.bin --dump > crushmap.json
rm crush.bin

echo "Collecting cluster status"
ceph -s -f json -o ceph_s.json
echo "Collecting monmap"
ceph mon dump -f json -o monmap.json
echo "Collecting ceph df"
ceph df -f json -o ceph_df.json
echo "Collecting ceph osd df"
ceph osd df -f json -o ceph_osd_df.json
echo "Collecting ceph osd dump"
ceph osd dump -f json -o ceph_osd_dump.json
echo "Collecting rados df"
rados df -f json >rados_df.json
echo "Collecting ceph report"
ceph report -o ceph_report.json
echo "Collecting auth data anonymized"
ceph auth list -f json |sed 's/AQ[^=]*==/KEY/g' > ceph_auth_ls.json
echo "Collecting ceph pg dump"
ceph pg dump -f json -o ceph_pg_dump.json
echo "Collecting ceph osd perf"
for i in {0..9}; do echo $i; ceph osd perf -f json -o ceph_osd_perf_$i.json; sleep 4; done

tar cjf "../"$ARCHNAME *
