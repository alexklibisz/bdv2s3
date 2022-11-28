#!/bin/bash
set -e
pg_isready -h $PGHOST -p $PGPORT -t 5
psql -v ON_ERROR_STOP=1 <<END_OF_SQL
select * from random_data order by id;
END_OF_SQL
