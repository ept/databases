# Which movies came out in 1995?
[movie for movie in movies if movie["year"] == 1995]

# ...which is the same as writing it out in full:
results = []
for movie in movies:
    if movie["year"] == 1995:
        results.append(movie)
