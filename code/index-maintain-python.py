def add_movie(movie_id, movie):   # keep both in step
    movies_by_id[movie_id] = movie
    year = movie["year"]
    movies_by_year.setdefault(year, []).append(movie_id)

add_movie("tt0113277", {"title": "Heat", "year": 1995})
# movies_by_year[1995] now lists three keys, not two
