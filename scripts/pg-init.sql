--
-- Trigger function
--
CREATE OR REPLACE FUNCTION objectid_notify() RETURNS trigger AS $$
DECLARE
BEGIN
  NOTIFY objectid_watch;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--
-- Example calendar month table
--
CREATE TABLE calendar_entry (  
  id serial PRIMARY KEY,
  calendar integer NOT NULL,
  title character varying(50),
  day date NOT NULL
);

CREATE TRIGGER objectid_watcher
    AFTER INSERT ON calendar_entry
    FOR EACH ROW
    EXECUTE PROCEDURE objectid_notify();

--
-- Example calendar table
--
CREATE TABLE calendar (    
  id serial PRIMARY KEY,  
  name character varying(100) NOT NULL,
  owner character varying(100) NOT NULL
);

CREATE TRIGGER objectid_watcher
    AFTER INSERT ON calendar
    FOR EACH ROW
    EXECUTE PROCEDURE objectid_notify();

--
-- Insert some example data
--
INSERT INTO calendar (id, name, owner) VALUES
  (1, 'Work', 'Steve Jobs'),
  (2, 'Work', 'Bill Gates');

INSERT INTO calendar_entry (id, calendar, title, day) VALUES
  (1, 1, 'Unveil the iPhone', '2007-06-29'),
  (2, 1, 'New iMac', '2007-08-07'),
  (3, 1, 'Launch Mac OS X 10.5', '2007-10-27'),
  (4, 1, 'Launch iPhone 3G', '2008-07-11'),
  (5, 2, 'Ralease Windows Vista', '2007-01-30');

--
-- ObjectID mapping table
--
CREATE TABLE objectid (
    id integer NOT NULL,
    type character(1) NOT NULL,
    oid character(24) NOT NULL
);

ALTER TABLE ONLY objectid ADD CONSTRAINT id_type PRIMARY KEY (id, type);
ALTER TABLE ONLY objectid ADD CONSTRAINT ntb_id_oid_key UNIQUE (oid);

