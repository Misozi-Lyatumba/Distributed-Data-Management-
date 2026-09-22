-- Distributed Database Assignment - Schema Setup
-- Create two schemas for distributed database demonstration

-- Create first schema (oracle01)
CREATE USER oracle01 IDENTIFIED BY oracle01_password
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

-- Grant necessary privileges
GRANT CONNECT, RESOURCE, DBA TO oracle01;
GRANT CREATE PUBLIC DATABASE LINK TO oracle01;
GRANT DROP PUBLIC DATABASE LINK TO oracle01;

-- Create second schema (oracle02)
CREATE USER oracle02 IDENTIFIED BY oracle02_password
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

-- Grant necessary privileges
GRANT CONNECT, RESOURCE, DBA TO oracle02;
GRANT CREATE PUBLIC DATABASE LINK TO oracle02;
GRANT DROP PUBLIC DATABASE LINK TO oracle02;

-- Commit the changes
COMMIT;
