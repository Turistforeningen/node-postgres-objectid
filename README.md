ObjectID for Postgres
=====================

So, we are in the progress of migrating some our our data from out primary
Postgres database over to our new MongoDB database. Since we have a lot of
smaller legacy systems, and one very big one, we would need to keep the two
databses in sync for a while. Since almost all tables had some kind of
refference to another table we needed to make a mapping between the incremental
Postgres-ID and the new MongoDB ObjectId. 

Here comes our little NodeJS background task to the rescue! It listens for new
rows in the Postgres table and generates a unique ObjectID which is inserted
into a mapping table for later refference.

The program will walk through all of the configured tables and create ObjectIDs
for them before it starts listening for new rows. This ensures that all of you
rconfigured tables have ObjectIDs even if the script stops for a while.

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

## Application Configuration

### Database Connection

### Configure Watch Tables

### Configure ObjectID Mapping Table

## Running

`npm start`

## Testing

`npm test`

