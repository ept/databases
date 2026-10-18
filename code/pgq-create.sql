INSTALL duckpgq FROM community;
LOAD duckpgq;

CREATE PROPERTY GRAPH movie_graph
VERTEX TABLES (movies, people)
EDGE TABLES (
  plays_role
    SOURCE KEY (person_id) REFERENCES people (person_id)
    DESTINATION KEY (movie_id) REFERENCES movies (movie_id)
);
