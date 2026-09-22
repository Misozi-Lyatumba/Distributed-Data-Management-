-- =====================================================
-- demo.sql
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
-- This script demonstrates the completed distributed database system.
-- It shows fragmentation results, reconstruction of vertical fragments,
-- remote retrieval from ORACLE02, and remote insertion into ORACLE02.
--
-- IMPORTANT:
-- Run the scripts in this order before running demo.sql:
-- 1. setup.sql    under SYSTEM_FREE
-- 2. site1.sql    under ORACLE01_SITE
-- 3. site2.sql    under ORACLE02_SITE
-- 4. demo.sql     under ORACLE01_SITE
-- =====================================================


-- =====================================================
-- 1. CHECK BASE TABLE RECORDS IN ORACLE01
-- Schema running this section: ORACLE01_SITE / oracle01
-- Purpose:
-- Confirm that the five base tables in ORACLE01 contain data.
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
-- 2. TASK 1: HORIZONTAL FRAGMENTATION OF DEPARTMENT
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment reference:
-- Department must be fragmented according to subsidiaries.
-- Subsidiary I: departments 100-220 and department 250
-- Subsidiary II: departments 221-370 except 250
-- Subsidiary III: departments 371-430
-- =====================================================

SELECT * FROM Department_Sub1;

-- Expected actual outcome:
-- 100   Human Resource   Lusaka   1   50000
-- 150   Accounts         Lusaka   2   80000
-- 250   Procurement      Ndola    3   75000

SELECT * FROM Department_Sub2;

-- Expected actual outcome:
-- 300   Sales   Kitwe   4   90000

SELECT * FROM Department_Sub3;

-- Expected actual outcome:
-- 380   ICT          Livingstone   5   120000
-- 420   Operations   Kabwe         6   100000

-- Explanation:
-- This proves horizontal fragmentation because the Department table
-- was split by rows according to department number ranges.


-- =====================================================
-- 3. TASK 2(a): DERIVED HORIZONTAL FRAGMENTATION OF EMPLOYEE
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment reference:
-- Emp1 should contain managers.
-- Emp2 should contain all other employees.
-- =====================================================

SELECT * FROM Emp1_Managers;

-- Expected actual outcome:
-- 1   John Banda     100   Lusaka       12000
-- 2   Mary Phiri     150   Lusaka       11000
-- 3   Peter Mwansa   250   Ndola        10500
-- 4   Ruth Tembo     300   Kitwe        9500
-- 5   Grace Zulu     380   Livingstone  13000
-- 6   David Chanda   420   Kabwe        12500

SELECT * FROM Emp2_NonManagers;

-- Expected actual outcome:
-- 7   Brian Sichone   300   Kitwe   7000
-- 8   Agnes Mumba     420   Kabwe   6500

-- Explanation:
-- This proves derived horizontal fragmentation because Employee was
-- split using the Department table. Employees whose empNo appears as
-- mgrEmpNo in Department are managers.


-- =====================================================
-- 4. TASK 2(b): DERIVED HORIZONTAL FRAGMENTATION OF PART
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment reference:
-- Part should be split into internal supplier parts and external supplier parts.
-- =====================================================

SELECT * FROM Partinternal;

-- Expected actual outcome:
-- 12   Office Desk      100   1500
-- 14   Server Machine   250   15000
-- 15   Network Switch   300   3000

SELECT * FROM Partexternal;

-- Expected actual outcome:
-- 10   Keyboard   501   500
-- 11   Printer    502   2500
-- 13   Mouse      501   250

-- Explanation:
-- This proves derived horizontal fragmentation because Part was split
-- using supplier information from the Supplier table.


-- =====================================================
-- 5. TASK 3: VERTICAL FRAGMENTATION OF EMPLOYEE
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment reference:
-- Employee should be split into column-based fragments:
-- name and address, department number, and name and salary.
-- =====================================================

SELECT * FROM Emp_Name_Address;

-- Expected actual outcome:
-- Should show empNo, empName, and address.

SELECT * FROM Emp_Department;

-- Expected actual outcome:
-- Should show empNo and deptNo.

SELECT * FROM Emp_Name_Salary;

-- Expected actual outcome:
-- Should show empNo, empName, and salary.

-- Explanation:
-- This proves vertical fragmentation because Employee was split by columns.
-- empNo is included in each fragment to allow reconstruction.


-- =====================================================
-- 6. RECONSTRUCT EMPLOYEE TABLE FROM VERTICAL FRAGMENTS
-- Schema running this section: ORACLE01_SITE / oracle01
-- Purpose:
-- Prove that the vertical fragments can be joined back together.
-- =====================================================

SELECT 
    a.empNo,
    a.empName,
    d.deptNo,
    a.address,
    s.salary
FROM Emp_Name_Address a
JOIN Emp_Department d
ON a.empNo = d.empNo
JOIN Emp_Name_Salary s
ON a.empNo = s.empNo;

-- Expected actual outcome:
-- 1   John Banda      100   Lusaka       12000
-- 2   Mary Phiri      150   Lusaka       11000
-- 3   Peter Mwansa    250   Ndola        10500
-- 4   Ruth Tembo      300   Kitwe        9500
-- 5   Grace Zulu      380   Livingstone  13000
-- 6   David Chanda    420   Kabwe        12500
-- 7   Brian Sichone   300   Kitwe        7000
-- 8   Agnes Mumba     420   Kabwe        6500

-- Explanation:
-- This confirms that no employee data was lost during vertical fragmentation.


-- =====================================================
-- 7. TASK 4: HYBRID FRAGMENTATION OF PART
-- Schema running this section: ORACLE01_SITE / oracle01
-- Assignment reference:
-- Part should be split by price into cheap and expensive parts.
-- Expensive parts should then be split into internal and external parts.
-- =====================================================

SELECT * FROM Part_Cheap;

-- Expected actual outcome:
-- 10   Keyboard   501   500
-- 13   Mouse      501   250

SELECT * FROM Part_Expensive_Internal;

-- Expected actual outcome:
-- 12   Office Desk      100   1500
-- 14   Server Machine   250   15000
-- 15   Network Switch   300   3000

SELECT * FROM Part_Expensive_External;

-- Expected actual outcome:
-- 11   Printer   502   2500

-- Explanation:
-- This proves hybrid fragmentation because Part was first split by price,
-- then expensive parts were further split by supplier type.


-- =====================================================
-- 8. CREATE DATABASE LINK FROM ORACLE01 TO ORACLE02
-- Schema running this section: ORACLE01_SITE / oracle01
-- Target schema: ORACLE02_SITE / oracle02
-- Purpose:
-- Allow ORACLE01 to access tables stored in ORACLE02.
-- =====================================================
-- Run this command only if the database link has not already been created.
-- If the link already exists, Oracle may return:
-- ORA-02011: duplicate database link name
-- That simply means the link already exists.

CREATE DATABASE LINK oracle02_link
CONNECT TO oracle02 IDENTIFIED BY oracle02pass
USING '(DESCRIPTION=
          (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))
          (CONNECT_DATA=(SERVICE_NAME=FREEPDB1))
       )';

-- Expected command outcome:
-- Database link ORACLE02_LINK created.


-- =====================================================
-- 9. REMOTE RETRIEVAL TEST
-- Schema running this section: ORACLE01_SITE / oracle01
-- Remote schema being accessed: ORACLE02_SITE / oracle02
-- Purpose:
-- Prove that ORACLE01 can read data stored in ORACLE02.
-- =====================================================

SELECT *
FROM Department_Sub2@oracle02_link;

-- Expected actual outcome before remote insert:
-- 300   Sales   Kitwe   4   90000

-- Explanation:
-- The query is run from ORACLE01, but the data is retrieved from ORACLE02
-- through the database link oracle02_link.


-- =====================================================
-- 10. REMOTE INSERT TEST
-- Schema running this section: ORACLE01_SITE / oracle01
-- Remote schema being inserted into: ORACLE02_SITE / oracle02
-- Purpose:
-- Prove that ORACLE01 can insert data into a table stored in ORACLE02.
-- =====================================================

INSERT INTO Department_Sub2@oracle02_link
VALUES (320, 'Marketing', 'Kitwe', 9, 60000);

COMMIT;

-- Expected command outcome:
-- 1 row inserted.
-- Commit complete.


-- =====================================================
-- 11. CONFIRM REMOTE INSERT
-- Schema running this section: ORACLE01_SITE / oracle01
-- Remote schema being checked: ORACLE02_SITE / oracle02
-- =====================================================

SELECT *
FROM Department_Sub2@oracle02_link;

-- Expected actual outcome after remote insert:
-- 300   Sales       Kitwe   4   90000
-- 320   Marketing   Kitwe   9   60000

-- Explanation:
-- This confirms that a new record was inserted into ORACLE02 while
-- the command was executed from ORACLE01.


-- =====================================================
-- 12. CHECK REMOTE FRAGMENT COUNTS THROUGH DATABASE LINK
-- Schema running this section: ORACLE01_SITE / oracle01
-- Remote schema being checked: ORACLE02_SITE / oracle02
-- Purpose:
-- Confirm the number of records stored remotely in ORACLE02.
-- =====================================================

SELECT 'DEPARTMENT_SUB2' AS table_name, COUNT(*) AS total_records FROM Department_Sub2@oracle02_link
UNION ALL
SELECT 'DEPARTMENT_SUB3', COUNT(*) FROM Department_Sub3@oracle02_link
UNION ALL
SELECT 'EMP2_NONMANAGERS', COUNT(*) FROM Emp2_NonManagers@oracle02_link
UNION ALL
SELECT 'PARTEXTERNAL', COUNT(*) FROM Partexternal@oracle02_link
UNION ALL
SELECT 'PART_EXPENSIVE_EXTERNAL', COUNT(*) FROM Part_Expensive_External@oracle02_link;

-- Expected actual outcome after remote insert:
-- DEPARTMENT_SUB2              2
-- DEPARTMENT_SUB3              2
-- EMP2_NONMANAGERS             2
-- PARTEXTERNAL                 3
-- PART_EXPENSIVE_EXTERNAL      1


-- =====================================================
-- END OF demo.sql
-- =====================================================
-- Final expected result:
-- This file demonstrates:
-- 1. Fragmentation results in ORACLE01.
-- 2. Reconstruction of vertical fragments.
-- 3. Remote retrieval from ORACLE02.
-- 4. Remote insertion into ORACLE02.
-- 5. Record counts from ORACLE02 through the database link.
--
-- Reminder:
-- Run this file under ORACLE01_SITE using F5 / Run Script.
-- =====================================================