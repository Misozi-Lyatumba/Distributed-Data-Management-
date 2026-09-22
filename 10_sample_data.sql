-- Sample Data for Distributed Database Demonstration
-- Connect as oracle01 before running this

-- Insert Departments (distributed across subsidiaries)
-- Subsidiary I departments (100-220 and 250)
INSERT INTO Dept_Subsidiary_I VALUES (100, 'Human Resources', 'Lusaka', 1001, 500000);
INSERT INTO Dept_Subsidiary_I VALUES (150, 'Finance', 'Lusaka', 1002, 750000);
INSERT INTO Dept_Subsidiary_I VALUES (200, 'IT', 'Lusaka', 1003, 600000);
INSERT INTO Dept_Subsidiary_I VALUES (220, 'Marketing', 'Lusaka', 1004, 450000);
INSERT INTO Dept_Subsidiary_I VALUES (250, 'Operations', 'Kitwe', 1005, 800000);

-- Subsidiary II departments (221-370, except 250)
INSERT INTO Dept_Subsidiary_II@link_to_oracle02 VALUES (221, 'Research', 'Ndola', 2001, 900000);
INSERT INTO Dept_Subsidiary_II@link_to_oracle02 VALUES (300, 'Development', 'Ndola', 2002, 850000);
INSERT INTO Dept_Subsidiary_II@link_to_oracle02 VALUES (350, 'Quality Control', 'Ndola', 2003, 400000);
INSERT INTO Dept_Subsidiary_II@link_to_oracle02 VALUES (370, 'Logistics', 'Ndola', 2004, 550000);

-- Subsidiary III departments (371-430)
INSERT INTO Dept_Subsidiary_III@link_to_oracle02 VALUES (371, 'Sales', 'Livingstone', 3001, 650000);
INSERT INTO Dept_Subsidiary_III@link_to_oracle02 VALUES (400, 'Customer Service', 'Livingstone', 3002, 350000);
INSERT INTO Dept_Subsidiary_III@link_to_oracle02 VALUES (430, 'Administration', 'Livingstone', 3003, 300000);

-- Insert Employees (managers and non-managers)
-- Managers (will go to Emp1)
INSERT INTO Emp1 VALUES (1001, 'John Smith', 100, '12 Main St Lusaka', 150000);
INSERT INTO Emp1 VALUES (1002, 'Mary Johnson', 150, '45 Oak Ave Lusaka', 160000);
INSERT INTO Emp1 VALUES (1003, 'David Brown', 200, '78 Pine Rd Lusaka', 140000);
INSERT INTO Emp1 VALUES (1004, 'Sarah Davis', 220, '23 Elm St Lusaka', 130000);
INSERT INTO Emp1 VALUES (1005, 'Michael Wilson', 250, '56 Cedar Ave Kitwe', 155000);
INSERT INTO Emp1 VALUES (2001, 'Robert Taylor', 221, '89 Birch Rd Ndola', 170000);
INSERT INTO Emp1 VALUES (2002, 'Jennifer Anderson', 300, '34 Maple St Ndola', 165000);
INSERT INTO Emp1 VALUES (2003, 'William Thomas', 350, '67 Oak Ave Ndola', 125000);
INSERT INTO Emp1 VALUES (2004, 'Lisa Jackson', 370, '12 Pine Rd Ndola', 135000);
INSERT INTO Emp1 VALUES (3001, 'James White', 371, '45 Elm St Livingstone', 145000);
INSERT INTO Emp1 VALUES (3002, 'Patricia Harris', 400, '78 Cedar Ave Livingstone', 120000);
INSERT INTO Emp1 VALUES (3003, 'Charles Martin', 430, '23 Birch Rd Livingstone', 115000);

-- Non-managers (will go to Emp2)
INSERT INTO Emp2 VALUES (1006, 'Thomas Garcia', 100, '89 Maple St Lusaka', 85000);
INSERT INTO Emp2 VALUES (1007, 'Linda Martinez', 150, '12 Oak Ave Lusaka', 90000);
INSERT INTO Emp2 VALUES (1008, 'Daniel Robinson', 200, '34 Pine Rd Lusaka', 88000);
INSERT INTO Emp2 VALUES (1009, 'Barbara Clark', 220, '67 Elm St Lusaka', 82000);
INSERT INTO Emp2 VALUES (1010, 'Christopher Lewis', 250, '90 Cedar Ave Kitwe', 95000);
INSERT INTO Emp2 VALUES (2005, 'Nancy Lee', 221, '23 Birch Rd Ndola', 92000);
INSERT INTO Emp2 VALUES (2006, 'Paul Walker', 300, '56 Maple St Ndola', 98000);
INSERT INTO Emp2 VALUES (2007, 'Karen Hall', 350, '89 Oak Ave Ndola', 87000);
INSERT INTO Emp2 VALUES (2008, 'Steven Allen', 370, '12 Pine Rd Ndola', 83000);
INSERT INTO Emp2 VALUES (3004, 'Michelle Young', 371, '45 Elm St Livingstone', 89000);
INSERT INTO Emp2 VALUES (3005, 'Donald King', 400, '78 Cedar Ave Livingstone', 81000);
INSERT INTO Emp2 VALUES (3006, 'Betty Wright', 430, '23 Birch Rd Livingstone', 79000);

-- Insert Suppliers (including internal suppliers)
-- External suppliers
INSERT INTO Supplier VALUES (5001, 'ABC Supplies', 'Lusaka');
INSERT INTO Supplier VALUES (5002, 'XYZ Manufacturing', 'Ndola');
INSERT INTO Supplier VALUES (5003, 'Global Parts Co', 'Kitwe');
INSERT INTO Supplier VALUES (5004, 'Local Hardware', 'Livingstone');

-- Internal suppliers (department numbers)
INSERT INTO Supplier VALUES (100, 'internal', 'Lusaka');
INSERT INTO Supplier VALUES (150, 'internal', 'Lusaka');
INSERT INTO Supplier VALUES (200, 'internal', 'Lusaka');
INSERT INTO Supplier VALUES (221, 'internal', 'Ndola');
INSERT INTO Supplier VALUES (371, 'internal', 'Livingstone');

-- Insert Parts (mixed internal and external, cheap and expensive)
-- Cheap external parts
INSERT INTO Partexternal VALUES (10001, 'Office Chair', 5001, 800);
INSERT INTO Partexternal VALUES (10002, 'Desk Lamp', 5002, 600);
INSERT INTO Partexternal VALUES (10003, 'Keyboard', 5003, 450);

-- Cheap internal parts
INSERT INTO Partinternal VALUES (10004, 'Stationery Set', 100, 350);
INSERT INTO Partinternal VALUES (10005, 'Cleaning Supplies', 150, 250);

-- Expensive external parts
INSERT INTO Partexternal VALUES (20001, 'Computer Server', 5001, 15000);
INSERT INTO Partexternal VALUES (20002, 'Industrial Printer', 5002, 12000);
INSERT INTO Partexternal VALUES (20003, 'Security System', 5003, 8500);

-- Expensive internal parts
INSERT INTO Partinternal VALUES (20004, 'Production Machine', 200, 25000);
INSERT INTO Partinternal VALUES (20005, 'Quality Equipment', 221, 18000);
INSERT INTO Partinternal VALUES (20006, 'Sales Display', 371, 11000);

-- Insert Stock records
INSERT INTO Stock VALUES (10001, 50);
INSERT INTO Stock VALUES (10002, 75);
INSERT INTO Stock VALUES (10003, 100);
INSERT INTO Stock VALUES (10004, 200);
INSERT INTO Stock VALUES (10005, 150);
INSERT INTO Stock VALUES (20001, 10);
INSERT INTO Stock VALUES (20002, 15);
INSERT INTO Stock VALUES (20003, 20);
INSERT INTO Stock VALUES (20004, 5);
INSERT INTO Stock VALUES (20005, 8);
INSERT INTO Stock VALUES (20006, 12);

COMMIT;
