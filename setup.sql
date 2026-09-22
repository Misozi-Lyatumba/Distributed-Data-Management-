-- setup.sql
-- Run this file as SYSTEM_FREE
-- Purpose: Create two schemas/sites for the distributed database assignment

CREATE USER oracle01 IDENTIFIED BY oracle01pass;

CREATE USER oracle02 IDENTIFIED BY oracle02pass;

GRANT CONNECT, RESOURCE TO oracle01;

GRANT CONNECT, RESOURCE TO oracle02;

GRANT CREATE SESSION TO oracle01;

GRANT CREATE SESSION TO oracle02;

GRANT CREATE TABLE TO oracle01;

GRANT CREATE TABLE TO oracle02;

GRANT CREATE DATABASE LINK TO oracle01;

ALTER USER oracle01 QUOTA UNLIMITED ON USERS;

ALTER USER oracle02 QUOTA UNLIMITED ON USERS;