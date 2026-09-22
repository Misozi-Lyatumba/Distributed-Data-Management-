-- Vertical Fragmentation for Employee Table
-- Connect as oracle01 before running this

-- Fragment 1: Name and Address
CREATE TABLE Emp_Name_Address (
    empNo NUMBER(6) PRIMARY KEY,
    empName VARCHAR2(100) NOT NULL,
    address VARCHAR2(200)
);

-- Fragment 2: Department Number
CREATE TABLE Emp_Dept (
    empNo NUMBER(6) PRIMARY KEY,
    deptNo NUMBER(4)
);

-- Fragment 3: Name and Salary
CREATE TABLE Emp_Name_Salary (
    empNo NUMBER(6) PRIMARY KEY,
    empName VARCHAR2(100) NOT NULL,
    salary NUMBER(10,2)
);

-- Create unified view for Employee using vertical fragments
CREATE VIEW Employee_Vertical AS
SELECT DISTINCT 
    n.empNo,
    n.empName,
    d.deptNo,
    n.address,
    s.salary
FROM Emp_Name_Address n
JOIN Emp_Dept d ON n.empNo = d.empNo
JOIN Emp_Name_Salary s ON n.empNo = s.empNo;

-- Instead of triggers for vertical fragmentation
CREATE OR REPLACE TRIGGER emp_vert_insert_trig
INSTEAD OF INSERT ON Employee_Vertical
FOR EACH ROW
BEGIN
    INSERT INTO Emp_Name_Address VALUES (:NEW.empNo, :NEW.empName, :NEW.address);
    INSERT INTO Emp_Dept VALUES (:NEW.empNo, :NEW.deptNo);
    INSERT INTO Emp_Name_Salary VALUES (:NEW.empNo, :NEW.empName, :NEW.salary);
END;
/

CREATE OR REPLACE TRIGGER emp_vert_update_trig
INSTEAD OF UPDATE ON Employee_Vertical
FOR EACH ROW
BEGIN
    -- Update name and address fragment
    UPDATE Emp_Name_Address 
    SET empName = :NEW.empName, address = :NEW.address
    WHERE empNo = :OLD.empNo;
    
    -- Update department fragment
    UPDATE Emp_Dept 
    SET deptNo = :NEW.deptNo
    WHERE empNo = :OLD.empNo;
    
    -- Update name and salary fragment
    UPDATE Emp_Name_Salary 
    SET empName = :NEW.empName, salary = :NEW.salary
    WHERE empNo = :OLD.empNo;
END;
/

CREATE OR REPLACE TRIGGER emp_vert_delete_trig
INSTEAD OF DELETE ON Employee_Vertical
FOR EACH ROW
BEGIN
    DELETE FROM Emp_Name_Address WHERE empNo = :OLD.empNo;
    DELETE FROM Emp_Dept WHERE empNo = :OLD.empNo;
    DELETE FROM Emp_Name_Salary WHERE empNo = :OLD.empNo;
END;
/

-- Note: Potential problems with vertical fragmentation:
-- 1. Data redundancy - empName appears in two fragments
-- 2. Join overhead - need to join fragments for queries
-- 3. Update anomalies - must update empName in multiple places
-- 4. Fragment dependency - fragments are not independent

COMMIT;
