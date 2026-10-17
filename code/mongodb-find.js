// Movies released in 2021 or later
db.movies.find({ year: { $gte: 2021 } })

// Movies with "War" among their genres
db.movies.find({ genres: "War" })

// Movies directed by Steven Spielberg
db.movies.find({ "directors.name": "Steven Spielberg" })
