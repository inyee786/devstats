#!/bin/sh
./grafana/influxdb_recreate.sh coredns_temp || exit 1
GHA2DB_CMDDEBUG=1 GHA2DB_RESETIDB=1 GHA2DB_LOCAL=1 GHA2DB_PROJECT=coredns PG_DB=coredns IDB_DB=coredns_temp ./gha2db_sync || exit 2
./grafana/influxdb_recreate.sh coredns || exit 3
./idb_backup coredns_temp coredns || 4
./grafana/influxdb_drop.sh coredns_temp
