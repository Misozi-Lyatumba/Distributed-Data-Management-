-- Hybrid Fragmentation for Parts Table
-- Connect as oracle01 before running this

-- First, horizontal fragmentation by price (cheap vs expensive)
-- Cheap parts: price <= ZMW 1000
CREATE TABLE Parts_Cheap AS
SELECT * FROM Part WHERE price <= 1000;

-- Expensive parts: price > ZMW 1000
CREATE TABLE Parts_Expensive AS
SELECT * FROM Part WHERE price > 1000;

-- Then, vertical fragmentation of expensive parts by supplier type
-- Expensive internal parts
CREATE TABLE Parts_Exp_Internal AS
SELECT p.* FROM Parts_Expensive p
WHERE p.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                   UNION
                   SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                   UNION
                   SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d);

-- Expensive external parts
CREATE TABLE Parts_Exp_External AS
SELECT p.* FROM Parts_Expensive p
WHERE p.suppNo NOT IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                       UNION
                       SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                       UNION
                       SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d);

-- Create unified view for hybrid fragmentation
CREATE VIEW Parts_Hybrid AS
SELECT * FROM Parts_Cheap
UNION ALL
SELECT * FROM Parts_Exp_Internal
UNION ALL
SELECT * FROM Parts_Exp_External;

-- Instead of triggers for hybrid fragmentation
CREATE OR REPLACE TRIGGER parts_hybrid_insert_trig
INSTEAD OF INSERT ON Parts_Hybrid
FOR EACH ROW
BEGIN
    IF :NEW.price <= 1000 THEN
        -- Cheap parts
        INSERT INTO Parts_Cheap VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
    ELSIF :NEW.price > 1000 THEN
        -- Expensive parts - check if internal or external
        IF :NEW.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) THEN
            INSERT INTO Parts_Exp_Internal VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
        ELSE
            INSERT INTO Parts_Exp_External VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER parts_hybrid_update_trig
INSTEAD OF UPDATE ON Parts_Hybrid
FOR EACH ROW
BEGIN
    -- Handle price change that might move part between fragments
    IF :OLD.price <= 1000 AND :NEW.price <= 1000 THEN
        -- Stay in cheap category
        UPDATE Parts_Cheap 
        SET partDescr = :NEW.partDescr, suppNo = :NEW.suppNo, price = :NEW.price
        WHERE partNo = :OLD.partNo;
    ELSIF :OLD.price <= 1000 AND :NEW.price > 1000 THEN
        -- Move from cheap to expensive
        DELETE FROM Parts_Cheap WHERE partNo = :OLD.partNo;
        IF :NEW.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) THEN
            INSERT INTO Parts_Exp_Internal VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
        ELSE
            INSERT INTO Parts_Exp_External VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
        END IF;
    ELSIF :OLD.price > 1000 AND :NEW.price <= 1000 THEN
        -- Move from expensive to cheap
        IF :OLD.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) THEN
            DELETE FROM Parts_Exp_Internal WHERE partNo = :OLD.partNo;
        ELSE
            DELETE FROM Parts_Exp_External WHERE partNo = :OLD.partNo;
        END IF;
        INSERT INTO Parts_Cheap VALUES (:NEW.partNo, :NEW.partDescr, :NEW.suppNo, :NEW.price);
    ELSE
        -- Stay in expensive category
        IF :OLD.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                           UNION
                           SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) THEN
            UPDATE Parts_Exp_Internal 
            SET partDescr = :NEW.partDescr, suppNo = :NEW.suppNo, price = :NEW.price
            WHERE partNo = :OLD.partNo;
        ELSE
            UPDATE Parts_Exp_External 
            SET partDescr = :NEW.partDescr, suppNo = :NEW.suppNo, price = :NEW.price
            WHERE partNo = :OLD.partNo;
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER parts_hybrid_delete_trig
INSTEAD OF DELETE ON Parts_Hybrid
FOR EACH ROW
BEGIN
    IF :OLD.price <= 1000 THEN
        DELETE FROM Parts_Cheap WHERE partNo = :OLD.partNo;
    ELSIF :OLD.suppNo IN (SELECT d.deptNo FROM Dept_Subsidiary_I d
                          UNION
                          SELECT d.deptNo FROM Dept_Subsidiary_II@link_to_oracle02 d
                          UNION
                          SELECT d.deptNo FROM Dept_Subsidiary_III@link_to_oracle02 d) THEN
        DELETE FROM Parts_Exp_Internal WHERE partNo = :OLD.partNo;
    ELSE
        DELETE FROM Parts_Exp_External WHERE partNo = :OLD.partNo;
    END IF;
END;
/

COMMIT;
