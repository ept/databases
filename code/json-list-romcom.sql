SELECT COUNT(*) FROM movies
WHERE  list_has_all(movie->>'$.genres[*]',
                    ['Romance', 'Comedy']);
