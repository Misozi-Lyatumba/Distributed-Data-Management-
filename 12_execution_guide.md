# Distributed Database Assignment - Execution Guide

## Overview
This guide provides step-by-step instructions for implementing and demonstrating the distributed database assignment using Oracle SQL Developer.

## Prerequisites
- Oracle Database installed (Oracle XE, Oracle Standard/Enterprise Edition)
- Oracle SQL Developer installed
- Appropriate DBA privileges to create users and database links

## Step-by-Step Execution

### Step 1: Schema Setup
1. **Connect as SYS or SYSTEM user** in SQL Developer
2. **Execute**: `01_setup_schemas.sql`
   - Creates two users: oracle01 and oracle02
   - Grants necessary privileges
3. **Verify**: Check that users were created successfully
   ```sql
   SELECT username FROM dba_users WHERE username IN ('ORACLE01', 'ORACLE02');
   ```

### Step 2: Base Table Creation
1. **Connect as oracle01** and execute: `02_base_tables_oracle01.sql`
2. **Connect as oracle02** and execute: `03_base_tables_oracle02.sql`
3. **Verify**: Tables should exist in both schemas
   ```sql
   SELECT table_name FROM user_tables;
   ```

### Step 3: Database Links Setup
1. **Connect as SYS or SYSTEM** and execute: `04_database_links.sql`
2. **Important**: Replace 'ORCL' with your actual database SID
3. **Test database links**:
   ```sql
   -- As oracle01
   SELECT * FROM dual@link_to_oracle02;
   
   -- As oracle02  
   SELECT * FROM dual@link_to_oracle01;
   ```

### Step 4: Horizontal Fragmentation
1. **Connect as oracle01** and execute: `05_horizontal_fragmentation.sql`
2. **Connect as oracle02** and execute: `06_horizontal_fragmentation_oracle02.sql`
3. **Verify** fragmentation:
   ```sql
   -- Check subsidiary I departments
   SELECT * FROM Dept_Subsidiary_I;
   
   -- Check remote subsidiary departments
   SELECT * FROM Dept_Subsidiary_II@link_to_oracle02;
   SELECT * FROM Dept_Subsidiary_III@link_to_oracle02;
   ```

### Step 5: Derived Horizontal Fragmentation
1. **Connect as oracle01** and execute: `07_derived_horizontal_fragmentation.sql`
2. **Verify** employee and part fragmentation:
   ```sql
   -- Check managers vs non-managers
   SELECT COUNT(*) as manager_count FROM Emp1;
   SELECT COUNT(*) as non_manager_count FROM Emp2;
   
   -- Check internal vs external parts
   SELECT COUNT(*) as internal_parts FROM Partinternal;
   SELECT COUNT(*) as external_parts FROM Partexternal;
   ```

### Step 6: Vertical Fragmentation
1. **Connect as oracle01** and execute: `08_vertical_fragmentation.sql`
2. **Verify** vertical fragments:
   ```sql
   -- Check each fragment
   SELECT * FROM Emp_Name_Address;
   SELECT * FROM Emp_Dept;
   SELECT * FROM Emp_Name_Salary;
   
   -- Check reconstructed view
   SELECT * FROM Employee_Vertical;
   ```

### Step 7: Hybrid Fragmentation
1. **Connect as oracle01** and execute: `09_hybrid_fragmentation.sql`
2. **Verify** hybrid fragmentation:
   ```sql
   -- Check each category
   SELECT COUNT(*) as cheap_parts FROM Parts_Cheap;
   SELECT COUNT(*) as exp_internal FROM Parts_Exp_Internal;
   SELECT COUNT(*) as exp_external FROM Parts_Exp_External;
   ```

### Step 8: Sample Data Population
1. **Connect as oracle01** and execute: `10_sample_data.sql`
2. **Verify** data insertion:
   ```sql
   -- Check department distribution
   SELECT COUNT(*) as dept_count FROM Dept_Subsidiary_I;
   SELECT COUNT(*) as dept_count FROM Dept_Subsidiary_II@link_to_oracle02;
   SELECT COUNT(*) as dept_count FROM Dept_Subsidiary_III@link_to_oracle02;
   ```

### Step 9: Demonstration Queries
1. **Connect as oracle01** and execute: `11_demonstration_queries.sql`
2. **Review** all query results to demonstrate:
   - Horizontal fragmentation
   - Derived horizontal fragmentation
   - Vertical fragmentation
   - Hybrid fragmentation
   - Remote data access
   - DML operations

## Demonstration Script for Assessment

### 1. Environment Setup
```sql
-- Show connected user
SELECT USER as current_user FROM dual;

-- Show database links are working
SELECT 'Link to oracle02 working' as status FROM dual@link_to_oracle02;
```

### 2. Horizontal Fragmentation Demo
```sql
-- Show transparent access
SELECT deptNo, deptName, area FROM Department WHERE deptNo BETWEEN 100 AND 220;

-- Show fragment location
SELECT 'Local' as location, deptNo, deptName FROM Dept_Subsidiary_I
UNION ALL
SELECT 'Remote' as location, deptNo, deptName FROM Dept_Subsidiary_II@link_to_oracle02;
```

### 3. Derived Fragmentation Demo
```sql
-- Show manager/non-manager split
SELECT 'Manager' as emp_type, empNo, empName FROM Emp1 WHERE ROWNUM <= 3
UNION ALL
SELECT 'Non-Manager' as emp_type, empNo, empName FROM Emp2 WHERE ROWNUM <= 3;
```

### 4. Vertical Fragmentation Demo
```sql
-- Show fragment reconstruction
SELECT empNo, empName, address, salary 
FROM Employee_Vertical 
WHERE ROWNUM <= 3;
```

### 5. Hybrid Fragmentation Demo
```sql
-- Show price-based and supplier-based fragmentation
SELECT partNo, partDescr, price,
       CASE WHEN price <= 1000 THEN 'Cheap' ELSE 'Expensive' END as price_category,
       CASE WHEN suppNo IN (100, 150, 200, 221, 371) THEN 'Internal' ELSE 'External' END as supplier_category
FROM Parts_Hybrid
WHERE ROWNUM <= 5;
```

## Common Issues and Solutions

### Database Link Issues
- **Problem**: ORA-02019: connection description for remote database not found
- **Solution**: Check database link name and tnsnames.ora configuration

### Privilege Issues
- **Problem**: ORA-01031: insufficient privileges
- **Solution**: Ensure user has CREATE DATABASE LINK privilege

### Fragmentation Issues
- **Problem**: Data not appearing in views
- **Solution**: Check that fragments were populated correctly

### Performance Issues
- **Problem**: Slow query performance across links
- **Solution**: Consider adding indexes on frequently queried columns

## Assessment Preparation Tips

1. **Practice each fragmentation type** independently
2. **Prepare explanations** for why each fragmentation strategy was chosen
3. **Be ready to discuss** trade-offs (performance vs complexity)
4. **Demonstrate DML operations** through views
5. **Explain vertical fragmentation problems** (data redundancy, join overhead)
6. **Show hybrid fragmentation logic** (horizontal + vertical combination)

## Report Structure Suggestions

1. **Introduction**: Distributed database concepts and objectives
2. **System Design**: Architecture diagram and fragmentation strategy
3. **Implementation**: Step-by-step setup and configuration
4. **Results**: Query performance and functionality demonstration
5. **Analysis**: Benefits, challenges, and trade-offs
6. **Conclusion**: Lessons learned and recommendations
7. **References**: Oracle documentation and distributed database literature

Remember to adjust database connection details (SID, passwords) according to your specific Oracle installation.
