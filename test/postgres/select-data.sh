#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 <<END_OF_SQL
select * from random_data order by id;
END_OF_SQL
