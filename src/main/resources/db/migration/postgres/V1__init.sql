CREATE TABLE school
(
    id   BIGSERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(50)           NOT NULL
);

CREATE TABLE student
(
    id        BIGSERIAL PRIMARY KEY         NOT NULL,
    name      VARCHAR(50)                   NOT NULL,
    school_id BIGINT REFERENCES school (id) NOT NULL
);
