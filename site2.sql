-- =====================================================
-- site2.sql
-- =====================================================
-- CONNECTION / SCHEMA TO USE:
-- Run this file under the ORACLE02_SITE connection.
--
-- In Oracle SQL Developer, make sure the active worksheet is connected to:
-- Connection Name: ORACLE02_SITE
-- Username: oracle02
--
-- HOW TO RUN:
-- Press F5 / Run Script.
-- Do NOT use Ctrl + Enter.
--
-- PURPOSE:
-- This script copies selected fragments from ORACLE01 into ORACLE02
-- to simulate distributed data allocation.
--
-- IMPORTANT:
-- Run site1.sql first under ORACLE01_SITE before running this file.
-- site1.sql creates the fragments and grants ORACLE02 permission to read them.
-- =====================================================


-- =====================================================
-- 1. COPY SELECTED FRAGMENTS FROM ORACLE01
-- Schema running this section: ORACLE02_SITE / oracle02
-- Source schema: ORACLE01_SITE / oracle01
-- Purpose:
-- Create local ORACLE02 copies of selected fragments from ORACLE01.
-- =====================================================

CREATE TABLE Department_Sub2 AS
SELECT *
FROM oracle01.Department_Sub2;

CREATE TABLE Department_Sub3 AS
SELECT *
FROM oracle01.Department_Sub3;

CREATE TABLE Emp2_NonManagers AS
SELECT *
FROM oracle01.Emp2_NonManagers;

CREATE TABLE Partexternal AS
SELECT *
FROM oracle01.Partexternal;

CREATE TABLE Part_Expensive_External AS
SELECT *
FROM oracle01.Part_Expensive_External;

-- Expected command outcome:
-- Table DEPARTMENT_SUB2 created.
-- Table DEPARTMENT_SUB3 created.
-- Table EMP2_NONMANAGERS created.
-- Table PARTEXTERNAL created.
-- Table PART_EXPENSIVE_EXTERNAL created.


-- =====================================================
-- 2. CHECK TABLES CREATED IN ORACLE02
-- Schema running this section: ORACLE02_SITE / oracle02
-- Purpose:
-- Confirm that the selected fragments now exist locally in ORACLE02.
-- =====================================================

SELECT table_name
FROM user_tables
WHERE table_name IN (
    'DEPARTMENT_SUB2',
    'DEPARTMENT_SUB3',
    'EMP2_NONMANAGERS',
    'PARTEXTERNAL',
    'PART_EXPENSIVE_EXTERNAL'
)
ORDER BY table_name;

-- Expected actual outcome:
-- DEPARTMENT_SUB2
-- DEPARTMENT_SUB3
-- EMP2_NONMANAGERS
-- PARTEXTERNAL
-- PART_EXPENSIVE_EXTERNAL


-- =====================================================
-- 3. CHECK RECORD COUNTS IN ORACLE02
-- Schema running this section: ORACLE02_SITE / oracle02
-- Purpose:
-- Confirm that the copied fragments contain the expected data.
-- =====================================================

SELECT 'DEPARTMENT_SUB2' AS table_name, COUNT(*) AS total_records FROM Department_Sub2
UNION ALL
SELECT 'DEPARTMENT_SUB3', COUNT(*) FROM Department_Sub3
UNION ALL
SELECT 'EMP2_NONMANAGERS', COUNT(*) FROM Emp2_NonManagers
UNION ALL
SELECT 'PARTEXTERNAL', COUNT(*) FROM Partexternal
UNION ALL
SELECT 'PART_EXPENSIVE_EXTERNAL', COUNT(*) FROM Part_Expensive_External;

-- Expected actual outcome:
-- DEPARTMENT_SUB2              1
-- DEPARTMENT_SUB3              2
-- EMP2_NONMANAGERS             2
-- PARTEXTERNAL                 3
-- PART_EXPENSIVE_EXTERNAL      1


-- =====================================================
-- END OF site2.sql
-- =====================================================
-- Final expected result:
-- ORACLE02_SITE now contains selected copied fragments from ORACLE01_SITE.
--
-- These fragments are:
-- 1. Department_Sub2
-- 2. Department_Sub3
-- 3. Emp2_NonManagers
-- 4. Partexternal
-- 5. Part_Expensive_External
--
-- Reminder:
-- Run this file under ORACLE02_SITE using F5 / Run Script.
-- =====================================================