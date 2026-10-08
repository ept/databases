-- name: Rows per position, and how many of them fill in the job column
-- headers: position, rows, with a job
-- tt: position
-- thousands: n, with_job
-- Evidence for q:position-tables: job is meaningful for some positions and not others,
-- which is the clearest sign that has_position holds more than one kind of thing.
SELECT position, count(*) AS n, count(job) AS with_job
FROM   has_position
GROUP BY position
ORDER BY n DESC;
