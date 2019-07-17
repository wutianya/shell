#!/bin/bash

bin_dir="/data/scripts"
backup_dir="/data/db_backup"
config="${bin_dir}/.db.config"
DATE=$(date +"%Y%m%d")
del_rule=2

[ -f $config ] && . $config
[ -f $config ] || { echo "config not exist"; exit 127; }

del_db_file() {
    local __cur_dir="/data/db_backup"
    local __bin_dir=$(pwd)
    [ "$__cur_dir" = "$__bin_dir" ] && {
        find . -mtime +$del_rule -name "db_simpletour_*" -type f |xargs rm -f 
    }
}

export PGPASSWORD=$(echo -n $password |base64 -d)
# ywuser
pg_dump -h $host -U $user  -p $port -d ywdb -F c -f $backup_dir/prod_ywdb_$DATE.dump  &
# yhuser
pg_dump -h $host -U $user  -p $port -d yhdb -F c -f $backup_dir/prod_yhdb_$DATE.dump 

sleep 5
cd $backup_dir  && {
    tar -zcf db_simpletour_${DATE}.tgz prod_*.dump
    rm -f prod_*.dump
}
if [ $(ls db_* |wc -l) -gt $del_rule ];then
    del_db_file
fi

# upload ftp
[ -f db_simpletour_${DATE}.tgz ] && $bin_dir/ftp_tool.sh --put db_simpletour_${DATE}.tgz  &> /dev/null
