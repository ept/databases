SELECT json_object(
         'movie_id', m.movie_id,
         'title',    m.title,
         'year',     m.year,
         'genres',   (SELECT list(g.name ORDER BY g.name)
                      FROM   has_genre AS h
                      JOIN   genres AS g USING (genre_id)
                      WHERE  h.movie_id = m.movie_id),
         'actors',   (SELECT list(json_object('person_id', p.person_id,
                                              'name', p.name))
                      FROM   has_position AS hp
                      JOIN   people AS p USING (person_id)
                      WHERE  hp.movie_id = m.movie_id
                        AND  hp.position = 'actor')
       ) AS doc
FROM   movies AS m;
