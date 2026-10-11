SELECT r.x FROM r WHERE r.y IN (SELECT s.y FROM s);

SELECT r.x FROM r JOIN s ON r.y = s.y;
