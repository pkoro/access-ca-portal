#!/bin/sh
for i in `sqlite3 db/dev.db .tables`
do echo ".mode csv
select * from $i;"|sqlite3 -header db/dev.db > test/fixtures/$i.csv
done
