-- Base Tables for Oracle02 Schema
-- Connect as oracle02 before running this script

-- Employee table
CREATE TABLE Employee (
    empNo NUMBER(6) PRIMARY KEY,
    empName VARCHAR2(100) NOT NULL,
    deptNo NUMBER(4),
    address VARCHAR2(200),
    salary NUMBER(10,2)
);

-- Department table
CREATE TABLE Department (
    deptNo NUMBER(4) PRIMARY KEY,
    deptName VARCHAR2(100) NOT NULL,
    area VARCHAR2(50),
    mgrEmpNo NUMBER(6),
    budget NUMBER(12,2),
    CONSTRAINT fk_dept_manager FOREIGN KEY (mgrEmpNo) REFERENCES Employee(empNo)
);

-- Part table
CREATE TABLE Part (
    partNo NUMBER(8) PRIMARY KEY,
    partDescr VARCHAR2(200) NOT NULL,
    suppNo NUMBER(6),
    price NUMBER(10,2)
);

-- Stock table
CREATE TABLE Stock (
    partNo NUMBER(8),
    stockNo NUMBER(6),
    CONSTRAINT pk_stock PRIMARY KEY (partNo, stockNo),
    CONSTRAINT fk_stock_part FOREIGN KEY (partNo) REFERENCES Part(partNo)
);

-- Supplier table
CREATE TABLE Supplier (
    suppNo NUMBER(6) PRIMARY KEY,
    suppName VARCHAR2(100) NOT NULL,
    town VARCHAR2(50)
);

-- Add foreign key constraint for Employee
ALTER TABLE Employee ADD CONSTRAINT fk_emp_dept 
FOREIGN KEY (deptNo) REFERENCES Department(deptNo);

-- Add foreign key constraint for Part
ALTER TABLE Part ADD CONSTRAINT fk_part_supplier 
FOREIGN KEY (suppNo) REFERENCES Supplier(suppNo);

COMMIT;
