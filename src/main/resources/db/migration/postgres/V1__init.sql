CREATE
EXTENSION IF NOT EXISTS "pgcrypto"; -- see https://www.starkandwayne.com/blog/uuid-primary-keys-in-postgresql/

CREATE TABLE school
(
    id   UUID DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL, -- use this uuid generation function so that the keys aren't so random and destroys indexing, see above blog post
    name VARCHAR(50)                                   NOT NULL
);

CREATE TABLE student
(
    id        UUID DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
    name      VARCHAR(50)                                   NOT NULL,
    school_id UUID REFERENCES school (id)                   NOT NULL
);
