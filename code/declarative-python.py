# scan every movie:      O(n)
[movie for movie in movies if movie["year"] == 1995]

# use the index:         O(log n)
[movies_by_id[key] for key in movies_by_year[1995]]
