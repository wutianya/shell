#!/bin/bash
export ETCDCTL_API=3
keys=$(etcdctl --cacert=/etc/ssl/etcd/ssl/ca.pem --cert=/etc/ssl/etcd/ssl/node-master.pem --key=/etc/ssl/etcd/ssl/node-master-key.pem get /registry --prefix -w json|python -m json.tool |grep key|cut -d ":" -f2|tr -d '"'|tr -d ",")
for x in $keys;do
    echo $x | base64 -d 
    echo 
done
