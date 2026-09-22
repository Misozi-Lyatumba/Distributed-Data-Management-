-- Database Links Setup
-- Run this as SYS or SYSTEM user to create public database links

-- Create database link from oracle01 to oracle02
CREATE PUBLIC DATABASE LINK link_to_oracle02
CONNECT TO oracle02 IDENTIFIED BY oracle02_password
USING 'ORCL';  -- Replace with your database SID

-- Create database link from oracle02 to oracle01
CREATE PUBLIC DATABASE LINK link_to_oracle01
CONNECT TO oracle01 IDENTIFIED BY oracle01_password
USING 'ORCL';  -- Replace with your database SID

-- Test the database links (run as oracle01)
-- SELECT * FROM dual@link_to_oracle02;

-- Test the database links (run as oracle02)  
-- SELECT * FROM dual@link_to_oracle01;

COMMIT;
