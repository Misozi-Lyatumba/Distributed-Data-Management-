-- Horizontal Fragmentation for Department Table
-- Based on subsidiary requirements:
-- Subsidiary I: departments 100-220 and department 250
-- Subsidiary II: departments 221-370 (except 250)  
-- Subsidiary III: departments 371-430

-- Connect as oracle01 before running this

-- Fragment for Subsidiary I at oracle01
CREATE TABLE Dept_Subsidiary_I AS
SELECT * FROM Department 
WHERE (deptNo BETWEEN 100 AND 220) OR deptNo = 250;

-- Fragment for Subsidiary II (will be moved to oracle02)
CREATE TABLE Dept_Subsidiary_II AS
SELECT * FROM Department 
WHERE deptNo BETWEEN 221 AND 370 AND deptNo != 250;

-- Fragment for Subsidiary III (will be moved to oracle02)
CREATE TABLE Dept_Subsidiary_III AS
SELECT * FROM Department 
WHERE deptNo BETWEEN 371 AND 430;

-- Create views to provide transparent access
CREATE VIEW Department AS
SELECT * FROM Dept_Subsidiary_I
UNION ALL
SELECT * FROM Dept_Subsidiary_II@link_to_oracle02
UNION ALL
SELECT * FROM Dept_Subsidiary_III@link_to_oracle02;

-- Instead of triggers for DML operations on the view
CREATE OR REPLACE TRIGGER dept_insert_trig
INSTEAD OF INSERT ON Department
FOR EACH ROW
BEGIN
    IF (:NEW.deptNo BETWEEN 100 AND 220) OR (:NEW.deptNo = 250) THEN
        INSERT INTO Dept_Subsidiary_I VALUES (:NEW.deptNo, :NEW.deptName, :NEW.area, :NEW.mgrEmpNo, :NEW.budget);
    ELSIF (:NEW.deptNo BETWEEN 221 AND 370) AND (:NEW.deptNo != 250) THEN
        INSERT INTO Dept_Subsidiary_II@link_to_oracle02 VALUES (:NEW.deptNo, :NEW.deptName, :NEW.area, :NEW.mgrEmpNo, :NEW.budget);
    ELSIF (:NEW.deptNo BETWEEN 371 AND 430) THEN
        INSERT INTO Dept_Subsidiary_III@link_to_oracle02 VALUES (:NEW.deptNo, :NEW.deptName, :NEW.area, :NEW.mgrEmpNo, :NEW.budget);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Department number outside valid range (100-430)');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER dept_update_trig
INSTEAD OF UPDATE ON Department
FOR EACH ROW
BEGIN
    IF (:OLD.deptNo BETWEEN 100 AND 220) OR (:OLD.deptNo = 250) THEN
        UPDATE Dept_Subsidiary_I 
        SET deptName = :NEW.deptName, area = :NEW.area, mgrEmpNo = :NEW.mgrEmpNo, budget = :NEW.budget
        WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 221 AND 370) AND (:OLD.deptNo != 250) THEN
        UPDATE Dept_Subsidiary_II@link_to_oracle02 
        SET deptName = :NEW.deptName, area = :NEW.area, mgrEmpNo = :NEW.mgrEmpNo, budget = :NEW.budget
        WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 371 AND 430) THEN
        UPDATE Dept_Subsidiary_III@link_to_oracle02 
        SET deptName = :NEW.deptName, area = :NEW.area, mgrEmpNo = :NEW.mgrEmpNo, budget = :NEW.budget
        WHERE deptNo = :OLD.deptNo;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER dept_delete_trig
INSTEAD OF DELETE ON Department
FOR EACH ROW
BEGIN
    IF (:OLD.deptNo BETWEEN 100 AND 220) OR (:OLD.deptNo = 250) THEN
        DELETE FROM Dept_Subsidiary_I WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 221 AND 370) AND (:OLD.deptNo != 250) THEN
        DELETE FROM Dept_Subsidiary_II@link_to_oracle02 WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 371 AND 430) THEN
        DELETE FROM Dept_Subsidiary_III@link_to_oracle02 WHERE deptNo = :OLD.deptNo;
    END IF;
END;
/

COMMIT;
