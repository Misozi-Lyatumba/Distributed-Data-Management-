-- =====================================================
-- site1.sql
-- =====================================================
-- CONNECTION / SCHEMA TO USE:
-- Run this file under the ORACLE01_SITE connection.
--
-- In Oracle SQL Developer, make sure the active worksheet is connected to:
-- Connection Name: ORACLE01_SITE
-- Username: oracle01
--
-- HOW TO RUN:
-- Press F5 / Run Script.
-- Do NOT use Ctrl + Enter.
--
-- PURPOSE:
-- This script creates the base tables in ORACLE01, inserts sample data,
-- creates all required fragments, and grants ORACLE02 permission to read
-- selected fragments.
-- =====================================================


-- =====================================================
-- 1. CREATE BASE TABLES
-- Schema running this section: ORACLE01_SITE / oracle01
-- =====================================================

CREATE TABLE Department (
    deptNo NUMBER PRIMARY KEY,
    deptName VARCHAR2(50),
    area VARCHAR2(50),
    mgrEmpNo NUMBER,
    budget NUMBER
);

CREATE TABLE Employee (
    empNo NUMBER PRIMARY KEY,
    empName VARCHAR2(50),
    deptNo NUMBER,
    address VARCHAR2(100),
    salary NUMBER
);

CREATE TABLE Supplier (
    suppNo NUMBER PRIMARY KEY,
    suppName VARCHAR2(50),
    town VARCHAR2(50)
);

CREATE TABLE Part (
    partNo NUMBER PRIMARY KEY,
    partDescr VARCHAR2(100),
    suppNo NUMBER,
    price NUMBER
);

CREATE TABLE Stock (
    partNo NUMBER,
    stockNo NUMBER,
    PRIMARY KEY (partNo, stockNo)
);

-- Expected command outcome:
-- Table DEPARTMENT created.
-- Table EMPLOYEE created.
-- Table SUPPLIER created.
-- Table PART created.
-- Table STOCK created.


-- =====================================================
-- 2. INSERT SAMPLE DATA
-- Schema running this section: ORACLE01_SITE / oracle01
-- =====================================================

INSERT INTO Department VALUES (100, 'Human Resource', 'Lusaka', 1, 50000);
INSERT INTO Department VALUES (150, 'Accounts', 'Lusaka', 2, 80000);
INSERT INTO Department VALUES (250, 'Procurement', 'Ndola', 3, 75000);
INSERT INTO Department VALUES (300, 'Sales', 'Kitwe', 4, 90000);
INSERT INTO Department VALUES (380, 'ICT', 'Livingstone', 5, 120000);
INSERT INTO Department VALUES (420, 'Operations', 'Kabwe', 6, 100000);

INSERT INTO Employee VALUES (1, 'John Banda', 100, 'Lusaka', 12000);
INSERT INTO Employee VALUES (2, 'Mary Phiri', 150, 'Lusaka', 11000);
INSERT INTO Employee VALUES (3, 'Peter Mwansa', 250, 'Ndola', 10500);
INSERT INTO Employee VALUES (4, 'Ruth Tembo', 300, 'Kitwe', 9500);
INSERT INTO Employee VALUES (5, 'Grace Zulu', 380, 'Livingstone', 13000);
INSERT INTO Employee VALUES (6, 'David Chanda', 420, 'Kabwe', 12500);
INSERT INTO Employee VALUES (7, 'Brian Sichone', 300, 'Kitwe', 7000);
INSERT INTO Employee VALUES (8, 'Agnes Mumba', 420, 'Kabwe', 6500);

INSERT INTO Supplier VALUES (100, 'internal', 'Lusaka');
INSERT INTO Supplier VALUES (250, 'internal', 'Ndola');
INSERT INTO Supplier VALUES (300, 'internal', 'Kitwe');
INSERT INTO Supplier VALUES (501, 'Tech Supplies Ltd', 'Lusaka');
INSERT INTO Supplier VALUES (502, 'Copperbelt Parts Ltd', 'Kitwe');

INSERT INTO Part VALUES (10, 'Keyboard', 501, 500);
INSERT INTO Part VALUES (11, 'Printer', 502, 2500);
INSERT INTO Part VALUES (12, 'Office Desk', 100, 1500);
INSERT INTO Part VALUES (13, 'Mouse', 501, 250);
INSERT INTO Part VALUES (14, 'Server Machine', 250, 15000);
INSERT INTO Part VALUES (15, 'Network Switch', 300, 3000);

INSERT INTO Stock VALUES (10, 1001);
INSERT INTO Stock VALUES (11, 1002);
INSERT INTO Stock VALUES (12, 1003);
INSERT INTO Stock VALUES (13, 1004);
INSERT INTO Stock VALUES (14, 1005);
INSERT INTO Stock VALUES (15, 1006);

COMMIT;

-- Expected command outcome:
-- 31 rows inserted in total.
-- Commit complete.


-- =====================================================
-- 3. HORIZONTAL FRAGMENTATION OF DEPARTMENT
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment task:
-- Subsidiary I: departments 100-220 and department 250
-- Subsidiary II: departments 221-370 except department 250
-- Subsidiary III: departments 371-430
-- =====================================================

CREATE TABLE Department_Sub1 AS
SELECT *
FROM Department
WHERE deptNo BETWEEN 100 AND 220
   OR deptNo = 250;

CREATE TABLE Department_Sub2 AS
SELECT *
FROM Department
WHERE deptNo BETWEEN 221 AND 370
  AND deptNo <> 250;

CREATE TABLE Department_Sub3 AS
SELECT *
FROM Department
WHERE deptNo BETWEEN 371 AND 430;

-- Expected command outcome:
-- Table DEPARTMENT_SUB1 created.
-- Table DEPARTMENT_SUB2 created.
-- Table DEPARTMENT_SUB3 created.


-- =====================================================
-- 4. DERIVED HORIZONTAL FRAGMENTATION OF EMPLOYEE
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment task:
-- Emp1 contains managers.
-- Emp2 contains all other employees.
-- =====================================================

CREATE TABLE Emp1_Managers AS
SELECT *
FROM Employee
WHERE empNo IN (
    SELECT mgrEmpNo
    FROM Department
);

CREATE TABLE Emp2_NonManagers AS
SELECT *
FROM Employee
WHERE empNo NOT IN (
    SELECT mgrEmpNo
    FROM Department
);

-- Expected command outcome:
-- Table EMP1_MANAGERS created.
-- Table EMP2_NONMANAGERS created.


-- =====================================================
-- 5. DERIVED HORIZONTAL FRAGMENTATION OF PART
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment task:
-- Split Part into internal and external supplier parts.
-- Internal suppliers have suppName = 'internal'.
-- =====================================================

CREATE TABLE Partinternal AS
SELECT p.*
FROM Part p
JOIN Supplier s
ON p.suppNo = s.suppNo
WHERE LOWER(s.suppName) = 'internal';

CREATE TABLE Partexternal AS
SELECT p.*
FROM Part p
JOIN Supplier s
ON p.suppNo = s.suppNo
WHERE LOWER(s.suppName) <> 'internal';

-- Expected command outcome:
-- Table PARTINTERNAL created.
-- Table PARTEXTERNAL created.


-- =====================================================
-- 6. VERTICAL FRAGMENTATION OF EMPLOYEE
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment task:
-- One fragment contains name and address.
-- Another fragment contains department number.
-- Another fragment contains name and salary.
-- =====================================================

CREATE TABLE Emp_Name_Address AS
SELECT empNo, empName, address
FROM Employee;

CREATE TABLE Emp_Department AS
SELECT empNo, deptNo
FROM Employee;

CREATE TABLE Emp_Name_Salary AS
SELECT empNo, empName, salary
FROM Employee;

-- Expected command outcome:
-- Table EMP_NAME_ADDRESS created.
-- Table EMP_DEPARTMENT created.
-- Table EMP_NAME_SALARY created.


-- =====================================================
-- 7. HYBRID FRAGMENTATION OF PART
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment task:
-- Split Part by price into cheap and expensive.
-- Then split expensive parts into internal and external parts.
-- =====================================================

CREATE TABLE Part_Cheap AS
SELECT *
FROM Part
WHERE price <= 1000;

CREATE TABLE Part_Expensive_Internal AS
SELECT p.*
FROM Part p
JOIN Supplier s
ON p.suppNo = s.suppNo
WHERE p.price > 1000
  AND LOWER(s.suppName) = 'internal';

CREATE TABLE Part_Expensive_External AS
SELECT p.*
FROM Part p
JOIN Supplier s
ON p.suppNo = s.suppNo
WHERE p.price > 1000
  AND LOWER(s.suppName) <> 'internal';

-- Expected command outcome:
-- Table PART_CHEAP created.
-- Table PART_EXPENSIVE_INTERNAL created.
-- Table PART_EXPENSIVE_EXTERNAL created.


-- =====================================================
-- 8. GRANT SELECT PERMISSION TO ORACLE02
-- Schema running this section: ORACLE01_SITE / oracle01
-- Target schema receiving permission: ORACLE02_SITE / oracle02
-- Purpose:
-- This allows ORACLE02 to copy selected fragments from ORACLE01.
-- =====================================================

GRANT SELECT ON Department_Sub2 TO oracle02;
GRANT SELECT ON Department_Sub3 TO oracle02;
GRANT SELECT ON Emp2_NonManagers TO oracle02;
GRANT SELECT ON Partexternal TO oracle02;
GRANT SELECT ON Part_Expensive_External TO oracle02;

-- Expected command outcome:
-- Grant succeeded.
-- Grant succeeded.
-- Grant succeeded.
-- Grant succeeded.
-- Grant succeeded.


-- =====================================================
-- 9. FINAL BASE TABLE COUNT CHECK
-- Schema running this section: ORACLE01_SITE / oracle01
-- Purpose:
-- Confirms that the original base tables have data.
-- =====================================================

SELECT 'DEPARTMENT' AS table_name, COUNT(*) AS total_records FROM Department
UNION ALL
SELECT 'EMPLOYEE', COUNT(*) FROM Employee
UNION ALL
SELECT 'SUPPLIER', COUNT(*) FROM Supplier
UNION ALL
SELECT 'PART', COUNT(*) FROM Part
UNION ALL
SELECT 'STOCK', COUNT(*) FROM Stock;

-- Expected actual outcome:
-- DEPARTMENT   6
-- EMPLOYEE     8
-- SUPPLIER     5
-- PART         6
-- STOCK        6


-- =====================================================
-- END OF site1.sql
-- =====================================================
-- Final expected result:
-- ORACLE01_SITE now contains:
-- 1. The five base tables.
-- 2. Sample data.
-- 3. All required fragmentation tables.
-- 4. SELECT permissions granted to ORACLE02 for selected fragments.
--
-- Reminder:
-- Run this file under ORACLE01_SITE using F5 / Run Script.
-- =====================================================