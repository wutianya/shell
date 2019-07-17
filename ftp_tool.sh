#!/usr/bin/env bash

ftp_ip="172.17.10.4"
ftp_port=21
ftp_user="simpletour"
ftp_passwd="mev5Je8IeSha"

do_ftp() {
    if [ -z $base_dir ];then
        base_dir="/tmp"
    fi
    if [ "$action" == "put" ];then
        action="mput"
        [ -f "$filename" ] && {
            base_dir=$(dirname $filename)
            filename=$(basename $filename)
        } || { echo "file does not exist"; exit 1; }
    else
        [ -f $base_dir/$filename ] && rm -f $base_dir/$filename
        echo "download file storage directory $base_dir"
        action="mget"
    fi
lftp $ftp_ip -p $ftp_port <<EOF
    user $ftp_user $ftp_passwd
    lcd $base_dir
    $action $filename
    close
    bye
EOF
}

show_usage() {
    echo -e "Usage: $(basename $0) [options] filename\n"
    echo "Options:"
    echo -e "  -d | --dir \t download dir"
    echo -e "  --get \t download file"
    echo -e "  --put \t uplaod file"
    echo -e "  -h \t print help"
    exit 0
}
while (($#));do
    case $1 in
        -d | --dir)
            base_dir=${2}
            shift 2;;
        --put)
            action="put"
            filename=${2}
            do_ftp
            echo "file upload succeed"
            exit 0
            ;;
        --get)
            action="get"
            filename=${2}
            do_ftp
            exit 0
            ;;
        
        -h | --help)
            show_usage
            ;;
        *)
            echo -e "\033[31mERROR: unknown argument! \033[0m\n" && show_usage 
            ;;
    esac
done
