The movies database for Datalog (Souffle)
=========================================

This is the example database of movies from the Databases course at the University of
Cambridge, as Datalog facts for Souffle (https://souffle-lang.github.io/).

The filming locations (the relations places, located_in and filmed_at) come from Wikidata
(https://www.wikidata.org/), which releases its data into the public domain (CC0).

    movies-schema.dl   the declarations of the relations (see the lecture notes)
    facts/             the facts, one tab-separated file per relation
    example.dl         an example program

To run the example, install Souffle (see https://souffle-lang.github.io/install), then run
the following in this directory:

    souffle -F facts -D- example.dl

-F facts tells Souffle where to find the facts, and -D- prints the output relations to
the terminal. To write your own program, start it with the line

    #include "movies-schema.dl"

like example.dl does, and save it in this directory.

You can also run Datalog programs without installing anything, in the Datalog playground
on the course web page, which already contains this database. In the playground, the
#include line is not needed.
