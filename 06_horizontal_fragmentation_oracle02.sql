-- Horizontal Fragmentation for Department Table at oracle02
-- Connect as oracle02 before running this

-- Fragment for Subsidiary II
CREATE TABLE Dept_Subsidiary_II AS
SELECT * FROM Department 
WHERE deptNo BETWEEN 221 AND 370 AND deptNo != 250;

-- Fragment for Subsidiary III
CREATE TABLE Dept_Subsidiary_III AS
SELECT * FROM Department 
WHERE deptNo BETWEEN 371 AND 430;

-- Create view to provide transparent access at oracle02
CREATE VIEW Department AS
SELECT * FROM Dept_Subsidiary_II
UNION ALL
SELECT * FROM Dept_Subsidiary_III
UNION ALL
SELECT * FROM Dept_Subsidiary_I@link_to_oracle01;

-- Instead of triggers for DML operations on the view
CREATE OR REPLACE TRIGGER dept_insert_trig
INSTEAD OF INSERT ON Department
FOR EACH ROW
BEGIN
    IF (:NEW.deptNo BETWEEN 100 AND 220) OR (:NEW.deptNo = 250) THEN
        INSERT INTO Dept_Subsidiary_I@link_to_oracle01 VALUES (:NEW.deptNo, :NEW.deptName, :NEW.area, :NEW.mgrEmpNo, :NEW.budget);
    ELSIF (:NEW.deptNo BETWEEN 221 AND 370) AND (:NEW.deptNo != 250) THEN
        INSERT INTO Dept_Subsidiary_II VALUES (:NEW.deptNo, :NEW.deptName, :NEW.area, :NEW.mgrEmpNo, :NEW.budget);
    ELSIF (:NEW.deptNo BETWEEN 371 AND 430) THEN
        INSERT INTO Dept_Subsidiary_III VALUES (:NEW.deptNo, :NEW.deptName, :NEW.area, :NEW.mgrEmpNo, :NEW.budget);
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
        UPDATE Dept_Subsidiary_I@link_to_oracle01 
        SET deptName = :NEW.deptName, area = :NEW.area, mgrEmpNo = :NEW.mgrEmpNo, budget = :NEW.budget
        WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 221 AND 370) AND (:OLD.deptNo != 250) THEN
        UPDATE Dept_Subsidiary_II 
        SET deptName = :NEW.deptName, area = :NEW.area, mgrEmpNo = :NEW.mgrEmpNo, budget = :NEW.budget
        WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 371 AND 430) THEN
        UPDATE Dept_Subsidiary_III 
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
        DELETE FROM Dept_Subsidiary_I@link_to_oracle01 WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 221 AND 370) AND (:OLD.deptNo != 250) THEN
        DELETE FROM Dept_Subsidiary_II WHERE deptNo = :OLD.deptNo;
    ELSIF (:OLD.deptNo BETWEEN 371 AND 430) THEN
        DELETE FROM Dept_Subsidiary_III WHERE deptNo = :OLD.deptNo;
    END IF;
END;
/

COMMIT;
