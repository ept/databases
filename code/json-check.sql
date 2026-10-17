CREATE TABLE people(
  person_id TEXT PRIMARY KEY,
  data      JSON NOT NULL,
  CHECK ((data->>'person_id') = person_id),
  CHECK (json_exists(data, '$.name')
         AND json_type(data, '$.name') = 'VARCHAR')
);
