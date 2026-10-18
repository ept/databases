MATCH path = SHORTEST 1
        (a:Person {name: 'Jennifer Lawrence'})
        -[:ACTED_IN]-+
        (b:Person {name: 'Daniel Radcliffe'})
RETURN length(path);
