-- Demonstration Queries for Distributed Database Assignment
-- Connect as oracle01 before running this

-- ============================================
-- 1. HORIZONTAL FRAGMENTATION DEMONSTRATION
-- ============================================

-- Query 1: Show all departments (transparent access across fragments)
SELECT 'All Departments' as query_type, deptNo, deptName, area, budget
FROM Department
ORDER BY deptNo;

-- Query 2: Show departments by subsidiary
SELECT 'Subsidiary I Departments' as query_type, deptNo, deptName, area, budget
FROM Dept_Subsidiary_I
ORDER BY deptNo;

SELECT 'Subsidiary II Departments (Remote)' as query_type, deptNo, deptName, area, budget
FROM Dept_Subsidiary_II@link_to_oracle02
ORDER BY deptNo;

SELECT 'Subsidiary III Departments (Remote)' as query_type, deptNo, deptName, area, budget
FROM Dept_Subsidiary_III@link_to_oracle02
ORDER BY deptNo;

-- ============================================
-- 2. DERIVED HORIZONTAL FRAGMENTATION DEMONSTRATION
-- ============================================

-- Query 3: Show managers vs non-managers
SELECT 'Managers' as query_type, empNo, empName, deptNo, salary
FROM Emp1
ORDER BY empNo;

SELECT 'Non-Managers' as query_type, empNo, empName, deptNo, salary
FROM Emp2
ORDER BY empNo;

-- Query 4: Show internal vs external parts
SELECT 'Internal Parts' as query_type, partNo, partDescr, suppNo, price
FROM Partinternal
ORDER BY partNo;

SELECT 'External Parts' as query_type, partNo, partDescr, suppNo, price
FROM Partexternal
ORDER BY partNo;

-- ============================================
-- 3. VERTICAL FRAGMENTATION DEMONSTRATION
-- ============================================

-- Query 5: Show vertical fragments
SELECT 'Name & Address Fragment' as query_type, empNo, empName, address
FROM Emp_Name_Address
ORDER BY empNo;

SELECT 'Department Fragment' as query_type, empNo, deptNo
FROM Emp_Dept
ORDER BY empNo;

SELECT 'Name & Salary Fragment' as query_type, empNo, empName, salary
FROM Emp_Name_Salary
ORDER BY empNo;

-- Query 6: Show reconstructed employee data
SELECT 'Reconstructed Employee Data' as query_type, empNo, empName, deptNo, address, salary
FROM Employee_Vertical
ORDER BY empNo;

-- ============================================
-- 4. HYBRID FRAGMENTATION DEMONSTRATION
-- ============================================

-- Query 7: Show hybrid fragments
SELECT 'Cheap Parts' as query_type, partNo, partDescr, price
FROM Parts_Cheap
ORDER BY partNo;

SELECT 'Expensive Internal Parts' as query_type, partNo, partDescr, price
FROM Parts_Exp_Internal
ORDER BY partNo;

SELECT 'Expensive External Parts' as query_type, partNo, partDescr, price
FROM Parts_Exp_External
ORDER BY partNo;

-- Query 8: Show all parts through hybrid view
SELECT 'All Parts (Hybrid View)' as query_type, partNo, partDescr, suppNo, price,
       CASE 
           WHEN price <= 1000 THEN 'Cheap'
           WHEN suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                          UNION
                          SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                          UNION
                          SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) 
           THEN 'Expensive Internal'
           ELSE 'Expensive External'
       END as category
FROM Parts_Hybrid
ORDER BY price, partNo;

-- ============================================
-- 5. REMOTE DATA ACCESS DEMONSTRATION
-- ============================================

-- Query 9: Cross-site joins
SELECT 'Cross-site Join: Employees with Remote Departments' as query_type, 
       e.empNo, e.empName, d.deptName, d.area
FROM Emp1 e
JOIN Dept_Subsidiary_II@link_to_oracle02 d ON e.deptNo = d.deptNo
ORDER BY e.empNo;

-- Query 10: Aggregation across fragments
SELECT 'Total Budget by Subsidiary' as query_type, 
       'Subsidiary I' as subsidiary, SUM(budget) as total_budget
FROM Dept_Subsidiary_I
UNION ALL
SELECT 'Total Budget by Subsidiary' as query_type, 
       'Subsidiary II' as subsidiary, SUM(budget) as total_budget
FROM Dept_Subsidiary_II@link_to_oracle02
UNION ALL
SELECT 'Total Budget by Subsidiary' as query_type, 
       'Subsidiary III' as subsidiary, SUM(budget) as total_budget
FROM Dept_Subsidiary_III@link_to_oracle02;

-- ============================================
-- 6. DML OPERATIONS DEMONSTRATION
-- ============================================

-- Query 11: Test insert through distributed view
INSERT INTO Department VALUES (450, 'New Department', 'Lusaka', NULL, 400000);

-- Query 12: Verify insert was routed correctly
SELECT 'New Department Insert Verification' as query_type, deptNo, deptName, area
FROM Dept_Subsidiary_I
WHERE deptNo = 450;

-- Query 13: Test update through distributed view
UPDATE Department SET budget = 450000 WHERE deptNo = 450;

-- Query 14: Test delete through distributed view
DELETE FROM Department WHERE deptNo = 450;

-- ============================================
-- 7. PERFORMANCE ANALYSIS QUERIES
-- ============================================

-- Query 15: Fragment size analysis
SELECT 'Fragment Size Analysis' as query_type, 'Dept_Subsidiary_I' as fragment_name, COUNT(*) as record_count
FROM Dept_Subsidiary_I
UNION ALL
SELECT 'Fragment Size Analysis' as query_type, 'Dept_Subsidiary_II (Remote)' as fragment_name, COUNT(*) as record_count
FROM Dept_Subsidiary_II@link_to_oracle02
UNION ALL
SELECT 'Fragment Size Analysis' as query_type, 'Dept_Subsidiary_III (Remote)' as fragment_name, COUNT(*) as record_count
FROM Dept_Subsidiary_III@link_to_oracle02
UNION ALL
SELECT 'Fragment Size Analysis' as query_type, 'Emp1 (Managers)' as fragment_name, COUNT(*) as record_count
FROM Emp1
UNION ALL
SELECT 'Fragment Size Analysis' as query_type, 'Emp2 (Non-Managers)' as fragment_name, COUNT(*) as record_count
FROM Emp2;

COMMIT;
