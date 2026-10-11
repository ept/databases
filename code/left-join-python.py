results = []
for movie in movies:                # every movie appears...
    matches = roles_by_movie_id.get(movie["movie_id"], [])
    for row in matches:
        results.append((movie["title"], row["role"]))
    if not matches:                 # ...even with no match
        results.append((movie["title"], None))
