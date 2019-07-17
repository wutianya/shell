#!/bin/bash
bin_dir="/data/scripts"
backup_dir="/data/db_backup"
config="${bin_dir}/.test.db.config"
now_date=$(date -d '-1 day' +"%Y%m%d")
yes_date=`date -d '-2 day' +%Y%m%d`
tar_date=`date +"%Y%m%d"`

[ -f $config ] && . $config
[ -f $config ] || { echo "config not exist"; exit 127; }

export PGPASSWORD=$(echo -n $test_password |base64 -d)

tar -zxf ${backup_dir}/db_simpletour_${tar_date}.tgz -C ${backup_dir}
sleep 5
for i in yw yh;do
if [ "`/usr/bin/psql -h $test_host -p $test_port -U $test_user -c '\l'|grep "uat_${i}db_${yes_date}"`" ];then
    select_sql="SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '""uat_${i}db_${yes_date}'";
    #echo ${select_sql}
    /usr/bin/psql -h $test_host -p $test_port -U $test_user -c "${select_sql}"
    /usr/bin/dropdb -h $test_host -p $test_port -U $test_user -e uat_${i}db_${yes_date}|| exit 1
fi
sleep 5
/usr/bin/createdb -h $test_host -p $test_port -U $test_user uat_${i}db_${now_date} -O ${i}user
sleep 5
/usr/bin/pg_restore -h $test_host -p $test_port  -U $test_user -d uat_${i}db_${now_date} <${backup_dir}/prod_${i}db_${tar_date}.dump
sleep 5
rm ${backup_dir}/prod_${i}db_${tar_date}.dump
done 
