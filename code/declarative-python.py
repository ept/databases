# Full scan over all movies, no index
[movie for movie in movies if movie["year"] == 1995]

# Look up using the movies_by_year index
[movies_by_id[key] for key in movies_by_year[1995]]
