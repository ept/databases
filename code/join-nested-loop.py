results = []
for movie in movies:                # for each movie...
    for rating in ratings:          # ...scan all of ratings
        if rating["movie_id"] == movie["movie_id"]:
            result = (movie["title"], rating["rating"])
            results.append(result)
