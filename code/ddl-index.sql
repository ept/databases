-- Make an index to efficiently find movies by year
CREATE INDEX movies_by_year ON movies (year);

-- Changed your mind, no longer want the index?
DROP INDEX movies_by_year;
