CREATE DATABASE trigger_test_db;

-- \c trigger_test_db;


CREATE OR REPLACE FUNCTION public.tf_stamp_last_update ()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.last_update = now();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TABLE example_table (id BIGSERIAL PRIMARY KEY, some_text VARCHAR(30), last_update timestamptz);

CREATE TRIGGER t_example_table_last_update
  BEFORE UPDATE ON example_table
  FOR EACH ROW
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE PROCEDURE public.tf_stamp_last_update();


INSERT INTO example_table (some_text, last_update) VALUES ('abcdef', now());
INSERT INTO example_table (some_text, last_update) VALUES ('gehijk', now());
INSERT INTO example_table (some_text, last_update) VALUES ('lmnopq', now());
INSERT INTO example_table (some_text, last_update) VALUES ('rstuvw', now());
INSERT INTO example_table (some_text, last_update) VALUES ('xyz123', now());

SELECT * FROM example_table;

UPDATE example_table SET some_text = 'updated!' WHERE  some_text = 'abcdef';
UPDATE example_table SET some_text = 'by primary key' WHERE id = 2;
UPDATE example_table SET some_text = 'xyz123' where some_text = 'xyz123';

SELECT * FROM example_table;