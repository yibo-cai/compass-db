#!/bin/bash
set -x

create_users_and_dbs() {
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    timeout=30
    # wait up to 30 secs...
    while ! /usr/bin/mysqladmin -u root status > /dev/null 2>&1
    do
        timeout=$(($timeout - 1))
        if [ $timeout -eq 0 ]; then
            echo -e "\nCould not connect to database server. Aborting..."
            exit 1
        fi
        echo -n "."
        sleep 1
    done

    echo "Creating user..."
    mysqladmin -h127.0.0.1 --port=3306 -u root password root
    mysql -h127.0.0.1 --port=3306 -uroot -proot -e "create database compass"
    mysql -h127.0.0.1 --port=3306 -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root'"
    mysqladmin -uroot -proot shutdown
}

listen_on_all_interfaces() {
    cat >> /etc/mysql/conf.d/mysql-listen-compass.cnf <<EOF
[mysqld]
bind-address=0.0.0.0
[mysqld_safe]
bind-address=0.0.0.0
EOF
}


if [[ -z ${1} ]]; then
    if [ ! -f /etc/mysql/conf.d/mysql-listen-compass.cnf ]; then
        create_users_and_dbs
        listen_on_all_interfaces
    fi
    /usr/bin/mysqld_safe
fi
