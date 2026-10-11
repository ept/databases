SELECT r.x FROM r LEFT JOIN s ON r.y = s.y AND s.z = 99;

SELECT r.x FROM r LEFT JOIN s ON r.y = s.y WHERE s.z = 99;
