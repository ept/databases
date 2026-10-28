MATCH (m:Movie)
WHERE EXISTS {
          (m)-[:FILMED_AT]->()-[:LOCATED_IN*0..]->
          (:Place {name: 'United Kingdom'}) }
  AND NOT EXISTS {
          (m)-[:FILMED_AT]->()-[:LOCATED_IN*0..]->
          (:Place {name: 'England'}) }
RETURN m.title, m.year;
