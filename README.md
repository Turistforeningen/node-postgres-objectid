ObjectID for Postgres
=====================

[![Build Status](https://drone.io/github.com/Turistforeningen/node-postgres-objectid/status.png)](https://drone.io/github.com/Turistforeningen/node-postgres-objectid/latest)

So, we are in the process of migrating some our hiking data from out primary
Postgres database over to a new MongoDB database. Since we have a lot of smaller
legacy systems, and one very big one, we would need to keep the two databses in
sync for a while. Since almost all tables had some kind of refference to another
table we needed to make a mapping between the incremental Postgres-ID and the
new MongoDB ObjectId to facilitate for easy update. 

Here comes our little NodeJS background task to the rescue! It listens for new
rows in the Postgres database, using the trigger/listen feature build right into
Postgres, and generates a unique ObjectID which is inserted into a mapping table
for later refference.

The program will go through all of the configured tables and create ObjectIDs
for all rows without before it starts to listen for new rows. This ensures that
all of your configured tables have an ObjectID even if the script stops for a
little while.

## Postgres Setup 

### Postgres Functon Definition

```plpgsql
CREATE OR REPLACE FUNCTION objectid_notify() RETURNS trigger AS $$
DECLARE
BEGIN
  NOTIFY objectid_watch;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Add Functon as Trigger

Remember to change `tbl_name` accordning to your database.

```plpgsql
CREATE TRIGGER objectid_watcher AFTER INSERT ON tbl_name
FOR EACH ROW EXECUTE PROCEDURE objectid_notify();
```

### Working Examples

You can look at
[this](https://github.com/Turistforeningen/node-postgres-objectid/blob/master/scripts/pg-init.sql)
sql file for a working example for a compatible database schema.

## Application Configuration

All application configurations are stored in the
[coffee/configure.coffee](https://github.com/Turistforeningen/node-postgres-objectid/blob/master/coffee/config.coffee)
configuration file.

### Database Connection

```coffee
exports.conString = 'postgres://postgres:1234@localhost:5432/test'
```

### Configure Watch Tables

```coffee
exports.from = [
  {table: 'calendar', type: 'C', colId: 'id'}
  {table: 'calendar_entry', type: 'E', colId: 'id'}
]
```

### Configure ObjectID Mapping Table

```coffee
exports.oid = {table: 'objectid', colType: 'type', colId: 'id', colOid: 'oid'}
```

## Testing

```shell
npm test
```

## Running

```shell
pm2 start .pm2-processes.json
```

## License

The MIT License (MIT)

Copyright (c) 2013 Turistforeningen

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

