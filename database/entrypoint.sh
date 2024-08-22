#!/bin/bash

if [[ -z "$MSSQL_SA_PASSWORD" ]]; then
    >&2 echo "MSSQL_SA_PASSWORD undefined - can't initialize the database"
    exit 1
fi

/usr/config/configure-db.sh &

/opt/mssql/bin/sqlservr
