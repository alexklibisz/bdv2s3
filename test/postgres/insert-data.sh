#!/bin/bash
set -e
pg_isready -h $PGHOST -p $PGPORT || sleep 5
pg_isready -h $PGHOST -p $PGPORT
time psql -v ON_ERROR_STOP=1 <<END_OF_SQL
drop table if exists random_data;
create table random_data (
  id bigserial primary key,
  int integer not null,
  str varchar(100) not null
);
insert into random_data(int, str)
select (random() * 1000000)::int, md5(random()::text)
from generate_series(1, 100000);
select * from random_data limit 10;
select count(*) from random_data;
END_OF_SQL
