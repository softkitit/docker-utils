#!/usr/bin/env bash

/wait

[ "$DEBUG" == 'true' ] && set -x

set -eo pipefail

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    echo "First container startup"
    touch $CONTAINER_ALREADY_STARTED
    if [ -n "$WSREP_NEW_CLUSTER" ]; then
        echo "New cluster init"
        #set -- "$@" --wsrep-new-cluster
        export PERFORM_MYSQL_DB_INIT=1
    else
        echo 'Skip MySql initialization'
    fi
else
    echo "Not first container startup"
fi

rm -rf /etc/mysql/my.cnf
touch /etc/mysql/my.cnf

if [ -n "$WSREP_CLUSTER_ADDRESS" -a "$1" == 'mysqld' ]; then

	echo '>> Creating Galera Config'
	export MYSQL_INITDB_SKIP_TZINFO="yes"
	export MYSQL_ALLOW_EMPTY_PASSWORD="yes"

	cat <<- EOF > /etc/mysql/my.cnf
	[client]
  socket=/var/run/mysqld/mysqld.sock
  default-character-set = utf8mb4

  [mysqld_safe]
  socket=/var/run/mysqld/mysqld.sock

  [mysql]
  default-character-set = utf8mb4

	[mysqld]
	user="mysql"
	bind-address="0.0.0.0"
	default_storage_engine="innodb"
	binlog_format="row"
	innodb_autoinc_lock_mode="2"
	innodb_flush_log_at_trx_commit="0"
	skip-external-locking
	innodb_locks_unsafe_for_binlog="1"
	wsrep_on="on"
	wsrep_provider="${WSREP_PROVIDER:-/usr/lib/galera/libgalera_smm.so}"
	wsrep_provider_options="${WSREP_PROVIDER_OPTIONS}"
	wsrep_cluster_address="${WSREP_CLUSTER_ADDRESS}"
	wsrep_cluster_name="${WSREP_CLUSTER_NAME:-my_wsrep_cluster}"
	wsrep_node_name="${WSREP_NODE_NAME:-$(hostname -s)}"
	wsrep_sst_auth="${WSREP_SST_AUTH:-secretKey}"
	wsrep_sst_method="${WSREP_SST_METHOD:-rsync}"
	character-set-server = utf8mb4

  pid-file=/var/run/mysqld/mysqld.pid
  socket=/var/run/mysqld/mysqld.sock
  basedir=/usr
  datadir=/var/lib/mysql
  tmpdir=/tmp
  lc-messages-dir=/usr/share/mysql
  log_error=/var/log/mysql/error.log

  slow_query_log=ON
  slow_query_log_file=/var/log/mysql/slow.log
  long_query_time=2


  symbolic-links=0

  skip-external-locking
  key_buffer_size = 256M
  max_allowed_packet = 256M
  table_open_cache = 256
  sort_buffer_size = 1M
  read_buffer_size = 1M
  read_rnd_buffer_size = 4M
  myisam_sort_buffer_size = 64M
  thread_cache_size = 8
  query_cache_size= 16M

  innodb_file_per_table

  max_connections=200
  max_user_connections=100
  wait_timeout=600
  interactive_timeout=50


  innodb_buffer_pool_size = "${INNODB_BUFFER_POOL_SIZE:-4G}"
  innodb_log_file_size = "${INNODB_LOG_FILE_SIZE:-1G}"
  innodb_flush_method = O_DIRECT
  innodb_thread_concurrency = 8
  skip_name_resolve = 1
  sql_mode = NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION




	EOF

	if [ -n "$WSREP_NODE_ADDRESS" ]; then
    		echo wsrep_node_address="${WSREP_NODE_ADDRESS}" >> /etc/mysql/my.cnf
	fi

elif [ -n "$WSREP_CLUSTER_ADDRESS" -a "$1" == 'garbd' ]; then

	echo '>> Configuring Garbd'
	set -- "$@" --address=$WSREP_CLUSTER_ADDRESS --group=${WSREP_CLUSTER_NAME:-my_wsrep_cluster} --name=$(hostname)

fi

exec /usr/local/bin/docker-entrypoint.sh "$@"
