results = []
for movie in movies:                # scan the movies
    rating = ratings_by_movie_id.get(movie["movie_id"])
    if rating is not None:          # no rating, no row
        results.append((movie["title"], rating))
