#!/bin/bash
set -e
pg_isready -h $PGHOST -p $PGPORT || sleep 5
pg_isready -h $PGHOST -p $PGPORT
psql -v ON_ERROR_STOP=1 <<END_OF_SQL
select * from random_data order by id;
END_OF_SQL
