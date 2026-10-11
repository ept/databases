results = []
for movie in movies:
    matched = False
    for row in plays_role:
        if row["movie_id"] == movie["movie_id"]:
            matched = True
            break
    if not matched:                 # no match, so output it
        results.append((movie["movie_id"], movie["title"]))
