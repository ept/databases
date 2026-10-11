results = []
for movie in movies:
    matched = False
    for role in plays_role:
        if role["movie_id"] == movie["movie_id"]:
            matched = True
            break
    if not matched:       # no match, so output it
        results.append(movie)
