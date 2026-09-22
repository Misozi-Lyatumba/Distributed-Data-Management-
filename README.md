CIT5641 DISTRIBUTED DATABASE ASSIGNMENT
Distributed Data Management Practical Implementation

This folder contains the SQL scripts used to create and demonstrate a distributed database system for the CIT5641 assignment.

The implementation uses two Oracle schemas to represent two database sites:

ORACLE01 = Site 1
ORACLE02 = Site 2

The system demonstrates:
1. Creation of two independent schemas/sites.
2. Creation of the assignment base tables.
3. Insertion of sample data.
4. Horizontal fragmentation.
5. Derived horizontal fragmentation.
6. Vertical fragmentation.
7. Hybrid fragmentation.
8. Allocation of selected fragments to Site 2.
9. Remote retrieval using a database link.
10. Remote insertion using a database link.


=====================================================
REQUIRED SOFTWARE
=====================================================

Before running these scripts, make sure the following are installed:

1. Oracle Database Free
2. Oracle SQL Developer

The database used in this project was Oracle AI Database Free, and the SQL tool used was Oracle SQL Developer.


=====================================================
DATABASE CONNECTION DETAILS USED
=====================================================

Host name: localhost
Port: 1521
Service name: FREEPDB1

If your Oracle installation uses a different service name, replace FREEPDB1 with your own service name.

Common service names may include:

FREEPDB1
FREE
XE
ORCL


=====================================================
IMPORTANT: HOW TO RUN THE SQL FILES
=====================================================

All .sql files should be run using F5 / Run Script in Oracle SQL Developer.

Do NOT use Ctrl + Enter.

Reason:

Ctrl + Enter usually runs only the current SQL statement where the cursor is placed.

F5 / Run Script runs the whole file from top to bottom.

Use F5 / Run Script for:

setup.sql
site1.sql
site2.sql
demo.sql


=====================================================
STEP 1: CREATE THE SYSTEM CONNECTION IN SQL DEVELOPER
=====================================================

Open Oracle SQL Developer.

On the left side, locate the Connections panel.

Right-click Connections and choose New Connection.

Enter the following details:

Connection Name: SYSTEM_FREE
Username: SYSTEM
Password: Enter the SYSTEM password created during Oracle Database installation
Hostname: localhost
Port: 1521
Service Name: FREEPDB1

Click Test.

Expected outcome:

Status: Success

Then click Connect.

Explanation:

The SYSTEM connection is the administrator connection. It is used only for administrative setup, such as creating ORACLE01 and ORACLE02 and granting them permissions.


=====================================================
STEP 2: RUN setup.sql AS SYSTEM
=====================================================

File to run:

setup.sql

Run under connection/schema:

SYSTEM_FREE

How to run:

Open setup.sql in Oracle SQL Developer and press F5 / Run Script.

Do not use Ctrl + Enter.

Purpose of setup.sql:

The setup.sql file creates the two schemas/sites:

ORACLE01
ORACLE02

It also grants the required permissions, including login access, table creation rights, storage quota, and permission for ORACLE01 to create a database link.

In simple terms, setup.sql prepares Site 1 and Site 2.

Expected command outcome:

User ORACLE01 created.
User ORACLE02 created.
Grant succeeded.
Grant succeeded.
User ORACLE01 altered.
User ORACLE02 altered.

Expected final outcome:

The two users/schemas should now exist:

ORACLE01 = Site 1
ORACLE02 = Site 2


=====================================================
STEP 3: CREATE THE ORACLE01 CONNECTION
=====================================================

After setup.sql has been run successfully, create a new connection for ORACLE01.

In SQL Developer:

Right-click Connections.
Click New Connection.

Enter the following:

Connection Name: ORACLE01_SITE
Username: oracle01
Password: oracle01pass
Hostname: localhost
Port: 1521
Service Name: FREEPDB1

Click Test.

Expected outcome:

Status: Success

Then click Connect.

Explanation:

ORACLE01_SITE is the first database site. It will store the original base tables and most of the fragments.


=====================================================
STEP 4: CREATE THE ORACLE02 CONNECTION
=====================================================

Create another connection for ORACLE02.

In SQL Developer:

Right-click Connections.
Click New Connection.

Enter the following:

Connection Name: ORACLE02_SITE
Username: oracle02
Password: oracle02pass
Hostname: localhost
Port: 1521
Service Name: FREEPDB1

Click Test.

Expected outcome:

Status: Success

Then click Connect.

Explanation:

ORACLE02_SITE is the second database site. It will store selected fragments copied from ORACLE01.


=====================================================
STEP 5: RUN site1.sql AS ORACLE01
=====================================================

File to run:

site1.sql

Run under connection/schema:

ORACLE01_SITE

How to run:

Open site1.sql in Oracle SQL Developer and press F5 / Run Script.

Do not use Ctrl + Enter.

Purpose of site1.sql:

This file creates the original assignment tables:

Department
Employee
Supplier
Part
Stock

It then inserts sample data into the tables.

After that, it creates all the required fragments:

1. Horizontal fragmentation of Department:
Department_Sub1
Department_Sub2
Department_Sub3

2. Derived horizontal fragmentation of Employee:
Emp1_Managers
Emp2_NonManagers

3. Derived horizontal fragmentation of Part:
Partinternal
Partexternal

4. Vertical fragmentation of Employee:
Emp_Name_Address
Emp_Department
Emp_Name_Salary

5. Hybrid fragmentation of Part:
Part_Cheap
Part_Expensive_Internal
Part_Expensive_External

At the end, site1.sql grants ORACLE02 permission to read selected fragments from ORACLE01.

Expected command outcome:

Table DEPARTMENT created.
Table EMPLOYEE created.
Table SUPPLIER created.
Table PART created.
Table STOCK created.

1 row inserted.
1 row inserted.
...
Commit complete.

Table DEPARTMENT_SUB1 created.
Table DEPARTMENT_SUB2 created.
Table DEPARTMENT_SUB3 created.
Table EMP1_MANAGERS created.
Table EMP2_NONMANAGERS created.
Table PARTINTERNAL created.
Table PARTEXTERNAL created.
Table EMP_NAME_ADDRESS created.
Table EMP_DEPARTMENT created.
Table EMP_NAME_SALARY created.
Table PART_CHEAP created.
Table PART_EXPENSIVE_INTERNAL created.
Table PART_EXPENSIVE_EXTERNAL created.

Grant succeeded.
Grant succeeded.
Grant succeeded.
Grant succeeded.
Grant succeeded.

Expected final count after site1.sql:

DEPARTMENT   6
EMPLOYEE     8
SUPPLIER     5
PART         6
STOCK        6

Explanation:

site1.sql builds Site 1. It creates the base tables, inserts sample records, creates all required fragments, and gives ORACLE02 permission to read selected fragments.


=====================================================
STEP 6: RUN site2.sql AS ORACLE02
=====================================================

File to run:

site2.sql

Run under connection/schema:

ORACLE02_SITE

How to run:

Open site2.sql in Oracle SQL Developer and press F5 / Run Script.

Do not use Ctrl + Enter.

Purpose of site2.sql:

This file copies selected fragments from ORACLE01 into ORACLE02.

The copied fragments are:

Department_Sub2
Department_Sub3
Emp2_NonManagers
Partexternal
Part_Expensive_External

This demonstrates distributed data allocation, where some fragments are stored at Site 2.

Expected command outcome:

Table DEPARTMENT_SUB2 created.
Table DEPARTMENT_SUB3 created.
Table EMP2_NONMANAGERS created.
Table PARTEXTERNAL created.
Table PART_EXPENSIVE_EXTERNAL created.

Expected table outcome:

DEPARTMENT_SUB2
DEPARTMENT_SUB3
EMP2_NONMANAGERS
PARTEXTERNAL
PART_EXPENSIVE_EXTERNAL

Expected record counts after site2.sql:

DEPARTMENT_SUB2              1
DEPARTMENT_SUB3              2
EMP2_NONMANAGERS             2
PARTEXTERNAL                 3
PART_EXPENSIVE_EXTERNAL      1

Explanation:

site2.sql builds Site 2 by copying selected fragments from ORACLE01 into ORACLE02. This proves that selected data has been allocated to another database site.


=====================================================
STEP 7: RUN demo.sql AS ORACLE01
=====================================================

File to run:

demo.sql

Run under connection/schema:

ORACLE01_SITE

How to run:

Open demo.sql in Oracle SQL Developer and press F5 / Run Script.

Do not use Ctrl + Enter.

Purpose of demo.sql:

This file demonstrates the final working system.

It shows:

1. The original base table record counts.
2. The results of horizontal fragmentation.
3. The results of derived horizontal fragmentation.
4. The results of vertical fragmentation.
5. Reconstruction of the Employee table from vertical fragments.
6. The results of hybrid fragmentation.
7. Creation of a database link from ORACLE01 to ORACLE02.
8. Remote retrieval from ORACLE02.
9. Remote insertion into ORACLE02.
10. Checking records stored remotely in ORACLE02.

Important:

Run demo.sql only once in a fresh setup.

If demo.sql is run more than once, the Marketing record may be inserted again into Department_Sub2 in ORACLE02.

Expected database link outcome:

Database link ORACLE02_LINK created.

Expected remote retrieval before remote insert:

300   Sales   Kitwe   4   90000

Expected remote insert command outcome:

1 row inserted.
Commit complete.

Expected remote retrieval after remote insert:

300   Sales       Kitwe   4   90000
320   Marketing   Kitwe   9   60000

Expected remote record counts after demo.sql:

DEPARTMENT_SUB2              2
DEPARTMENT_SUB3              2
EMP2_NONMANAGERS             2
PARTEXTERNAL                 3
PART_EXPENSIVE_EXTERNAL      1

Explanation:

demo.sql proves that ORACLE01 can access ORACLE02 remotely using a database link. It also proves that ORACLE01 can insert data into a table stored in ORACLE02.


=====================================================
IMPORTANT NOTE ABOUT DATABASE LINK
=====================================================

The database link is created in demo.sql using this connection descriptor:

Host: localhost
Port: 1521
Service Name: FREEPDB1

If your service name is different, edit demo.sql and replace FREEPDB1 with the correct service name.

For example, if your service name is XE, replace:

SERVICE_NAME=FREEPDB1

with:

SERVICE_NAME=XE


=====================================================
SCRIPT RUN ORDER SUMMARY
=====================================================

Run the scripts in this order:

1. setup.sql
Run as: SYSTEM_FREE
Run using: F5 / Run Script

2. site1.sql
Run as: ORACLE01_SITE
Run using: F5 / Run Script

3. site2.sql
Run as: ORACLE02_SITE
Run using: F5 / Run Script

4. demo.sql
Run as: ORACLE01_SITE
Run using: F5 / Run Script


=====================================================
EXPECTED CONNECTIONS IN SQL DEVELOPER
=====================================================

After setup, SQL Developer should have these connections:

SYSTEM_FREE
ORACLE01_SITE
ORACLE02_SITE


=====================================================
IMPORTANT WARNINGS
=====================================================

These scripts are designed for a fresh Oracle setup.

If the users, tables, fragments or database link already exist, Oracle may return errors such as:

ORA-01920: user name conflicts with another user or role name
ORA-00955: name is already used by an existing object
ORA-02011: duplicate database link name

These errors simply mean that the object already exists.

For a fresh run, use a clean Oracle environment or drop the existing objects first.

Always run the files using F5 / Run Script.


=====================================================
ASSIGNMENT PURPOSE
=====================================================

The purpose of this implementation is to show that a distributed database can be designed by splitting relations into fragments, storing selected fragments across two database schemas, and accessing remote data through a database link.

ORACLE01_SITE acts as the main site.
ORACLE02_SITE acts as the second distributed site.

Remote retrieval and remote insertion are demonstrated from ORACLE01_SITE to ORACLE02_SITE.
