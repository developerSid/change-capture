CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- see https://www.starkandwayne.com/blog/uuid-primary-keys-in-postgresql/

CREATE FUNCTION last_updated_column_fn()
    RETURNS TRIGGER AS
$$
BEGIN
    new.time_updated := clock_timestamp();

    IF new.id <> old.id THEN -- help ensure that the uu_row_id can't be updated once it is created
        RAISE EXCEPTION 'cannot update id once it has been created';
    END IF;

    RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE TABLE day_of_week_type_domain
(
    id          INTEGER     NOT NULL PRIMARY KEY,
    value       VARCHAR(10) NOT NULL,
    description VARCHAR(15) NOT NULL
);
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (1, 'SUNDAY', 'Sunday');
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (2, 'MONDAY', 'Monday');
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (3, 'TUESDAY', 'Tuesday');
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (4, 'WEDNESDAY', 'Wednesday');
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (5, 'THURSDAY', 'Thursday');
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (6, 'FRIDAY', 'Friday');
INSERT INTO day_of_week_type_domain(id, value, description) VALUES (7, 'SATURDAY', 'Saturday');

CREATE TABLE university
(
    id           UUID        DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL, -- use this uuid generation function so that the keys aren't so random and destroys indexing, see above blog post
    time_created TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    time_updated TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    name         VARCHAR(50) CHECK ( char_length(trim(name)) > 1 )    NOT NULL
);
CREATE TRIGGER update_university_trg
    BEFORE UPDATE
    ON university
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated_column_fn();

CREATE TABLE student
(
    id            UUID        DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
    name          VARCHAR(50) CHECK ( char_length(trim(name)) > 1 )    NOT NULL,
    time_created  TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    time_updated  TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    university_id UUID REFERENCES university (id)                      NOT NULL
);
CREATE TRIGGER update_student_trg
    BEFORE UPDATE
    ON student
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated_column_fn();

CREATE TABLE annex
(
    id            UUID        DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
    name          VARCHAR(50) CHECK ( char_length(trim(name)) > 1 )    NOT NULL,
    time_created  TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    time_updated  TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    university_id UUID REFERENCES university (id)                      NOT NULL
);
CREATE TRIGGER update_annex_trg
    BEFORE UPDATE
    ON annex
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated_column_fn();

CREATE TABLE class
(
    id            UUID        DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
    name          VARCHAR(50) CHECK ( char_length(trim(name)) > 1 )    NOT NULL,
    time_created  TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    time_updated  TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    university_id UUID REFERENCES university (id)                      NOT NULL
);
CREATE TRIGGER update_class_trg
    BEFORE UPDATE
    ON class
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated_column_fn();

CREATE TABLE class_day_of_week
(
    class_id       UUID REFERENCES class (id)          NOT NULL,
    day_of_week_id INTEGER REFERENCES day_of_week (id) NOT NULL
);

CREATE TABLE annex_class
(
    id              UUID        DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
    number_of_seats INTEGER CHECK (number_of_seats > 0)                  NOT NULL,
    time_created    TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    time_updated    TIMESTAMPTZ DEFAULT clock_timestamp()                NOT NULL,
    class_id        UUID REFERENCES class (id)                           NOT NULL,
    annex_id        UUID REFERENCES annex (id)                           NOT NULL
);

CREATE TABLE student_annex_class
(
    student_id        UUID REFERENCES student(id) NOT NULL,
    annex_class_id    UUID REFERENCES annex_class(id) NOT NULL
);