-- Derived Horizontal Fragmentation
-- Connect as oracle01 before running this

-- Part A: Employee Fragmentation (Managers vs Non-Managers)

-- Create Emp1 fragment for managers
CREATE TABLE Emp1 AS
SELECT e.* FROM Employee e
WHERE e.empNo IN (SELECT d.mgrEmpNo FROM Department d WHERE d.mgrEmpNo IS NOT NULL);

-- Create Emp2 fragment for non-managers  
CREATE TABLE Emp2 AS
SELECT e.* FROM Employee e
WHERE e.empNo NOT IN (SELECT d.mgrEmpNo FROM Department d WHERE d.mgrEmpNo IS NOT NULL);

-- Create unified view for Employee
CREATE VIEW Employee AS
SELECT * FROM Emp1
UNION ALL
SELECT * FROM Emp2;

-- Instead of triggers for Employee view
CREATE OR REPLACE TRIGGER emp_insert_trig
INSTEAD OF INSERT ON Employee
FOR EACH ROW
BEGIN
    -- Check if this employee is a manager
    IF :NEW.empNo IN (SELECT d.mgrEmpNo FROM Dept_Subsidiary_I d WHERE d.mgrEmpNo IS NOT NULL
                      UNION
                      SELECT d.mgrEmpNo FROM Dept_Subsidiary_II@link_to_oracle02 d WHERE d.mgrEmpNo IS NOT NULL
                      UNION
                      SELECT d.mgrEmpNo FROM Dept_Subsidiary_III@link_to_oracle02 d WHERE d.mgrEmpNo IS NOT NULL) THEN
        INSERT INTO Emp1 VALUES (:NEW.empNo, :NEW.empName, :NEW.deptNo, :NEW.address, :NEW.salary);
    ELSE
        INSERT INTO Emp2 VALUES (:NEW.empNo, :NEW.empName, :NEW.deptNo, :NEW.address, :NEW.salary);
    END IF;
END;
/

-- Part B: Part Fragmentation (Internal vs External Suppliers)

-- Create Partinternal fragment (internal suppliers)
CREATE TABLE Partinternal AS
SELECT p.* FROM Part p
WHERE p.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                   UNION
                   SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                   UNION
                   SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d);

-- Create Partexternal fragment (external suppliers)
CREATE TABLE Partexternal AS
SELECT p.* FROM Part p
WHERE p.suppNo NOT IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                       UNION
                       SELECT d.mgrEmpNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                       UNION
                       SELECT d.mgrEmpNo FROM Dept_Subsidiary_III@link_to_oracle02 d);

-- Create unified view for Part
CREATE VIEW Part AS
SELECT * FROM Partinternal
UNION ALL
SELECT * FROM Partexternal;

-- Instead of triggers for Part view
CREATE OR REPLACE TRIGGER part_insert_trig
INSTEAD OF INSERT ON Part
FOR EACH ROW
BEGIN
    -- Check if supplier is internal (department number)
    IF :NEW.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                      UNION
                      SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                      UNION
                      SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) THEN
        INSERT INTO Partinternal VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
    ELSE
        INSERT INTO Partexternal VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
    END IF;
END;
/

COMMIT;
