Add MongoDB ObjectID to rows in Postgres
========================================

## Postgres Trigger Functions

Remember to alter all instances of `tbl_name` and `tbl_id` accordingly.

### Create Postgres Functon Definition


```plpgsql
CREATE OR REPLACE FUNCTION tbl_name_notify_trigger() RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify('watchers', TG_TABLE_NAME || ',tbl_id,' || NEW.tbl_id );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Add Functon as Trigger

```plpgsql
CREATE TRIGGER tbl_name_watch_trigger AFTER INSERT ON tbl_name
FOR EACH ROW EXECUTE PROCEDURE tbl_name_notify_trigger();
```

