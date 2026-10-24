CREATE TABLE vertices(
  vertex_id   INT PRIMARY KEY,
  label       TEXT,   -- e.g. 'Movie' or 'Person'
  properties  JSON    -- e.g. {"name": "Charles Chaplin"}
);

CREATE TABLE edges(
  edge_id     INT PRIMARY KEY,
  tail_vertex INT REFERENCES vertices(vertex_id),
  head_vertex INT REFERENCES vertices(vertex_id),
  type        TEXT,   -- e.g. 'ACTED_IN'
  properties  JSON    -- e.g. {"roles": ["A Tramp"]}
);

CREATE INDEX edges_tails ON edges(tail_vertex);
CREATE INDEX edges_heads ON edges(head_vertex);
