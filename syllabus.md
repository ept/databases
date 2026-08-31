# Syllabus for Databases (2026/27)

## Aims

Databases are an essential part of modern computing, forming the foundation of most online apps and services. As databases have grown to support extremely large datasets and huge query volumes, specialised databases for a range of different workloads have emerged. Relational databases and SQL have been the dominant paradigm for half a century, and they continue to be widely used, but other data models and query languages have also emerged.

This course introduces the fundamentals of database systems from an application developer’s perspective. That is, the focus is more on the abstractions offered by database management systems, and less on how those abstractions are implemented internally. It compares different approaches to data modelling: relational, graph-oriented, and document-oriented models. It emphasises the engineering trade-offs and guides students towards being able to choose “the right tool for the job”.

## Lectures

* **Introduction**. How, where, and why databases are used. Comparing databases, filesystems, key-value stores, and data structures. Logical vs. physical data representations.  
* **Relational databases**. Tables, indexes, primary keys, foreign keys, referential integrity. Entities, one-to-one, one-to-many, and many-to-many relationships. SQL DDL and DML.  
* **Relational queries**. Introduction to SQL, relational algebra, and Datalog. Selection, projection, renaming, cartesian product, inner joins, outer joins, union, intersection, difference.  
* **Further SQL**. Multisets, NULL values, grouping, aggregation, ACID transactions. Normalisation and redundancy.  
* **Document-oriented data**. Storing and querying JSON data. Trade-offs between relational and document-oriented data modelling.  
* **Graph-oriented data**. Vertices, edges, property graphs. Cypher and GQL. Comparison with relational and document model.  
* **Recursive queries**. Tree traversal, graph algorithms. Recursive CTEs in SQL, variable-length paths in Cypher, recursive rules in Datalog.  
* **Database system trade-offs**. Row-oriented vs. column-oriented databases. OLTP vs. analytics. Single-node vs. distributed vs. embedded databases.

## Objectives

At the end of the course students should:

* be able to model data for a variety of applications using relational, graph, and document data models;  
* be comfortable using the core feature set of SQL to write queries;  
* have an appreciation for other query languages (relational algebra, Datalog, Cypher) and be able to compare these to SQL;  
* know how to navigate the trade-offs between different approaches to databases, and how to choose a system that is a good fit for a particular application.

## Recommended reading

Lemahieu, W., vanden Broucke, S. and Baesens, B. (2018). *Principles of Database Management*. Cambridge University Press.
