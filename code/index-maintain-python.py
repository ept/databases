def add_movie(movie_id, movie):   # keep both in step
    movies_by_id[movie_id] = movie
    year = movie["year"]
    movies_by_year.setdefault(year, []).append(movie_id)
