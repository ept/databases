movies = [
    {"title": "Alien", "year": 1979, "minutes": 117},
    {"title": "Se7en", "year": 1995, "minutes": 127},
    {"title": "Toy Story", "year": 1995, "minutes": 81},
]

# Which movies came out in 1995?
[movie for movie in movies if movie["year"] == 1995]
