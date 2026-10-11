results = []
for movie in movies:                # for each movie...
    for row in ratings:             # ...scan all of ratings
        if row["movie_id"] == movie["movie_id"]:
            results.append((movie["title"], row["rating"]))
