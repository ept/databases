CREATE TABLE people(
  person_id TEXT PRIMARY KEY,
  person    JSON NOT NULL,
  CHECK ((person->>'person_id') = person_id),
  CHECK (json_exists(person, '$.name')
         AND json_type(person, '$.name') = 'VARCHAR')
);
