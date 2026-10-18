SELECT   title, role, name
FROM     GRAPH_TABLE (movie_graph
           MATCH (p:people)-[r:plays_role]->(m:movies)
           WHERE m.title = 'The Kid'
           COLUMNS (m.title, r.role, p.name))
ORDER BY role
LIMIT    4;
