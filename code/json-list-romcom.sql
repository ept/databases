SELECT COUNT(*) FROM movies
WHERE  list_has_all(data->>'$.genres[*]',
                    ['Romance', 'Comedy']);
