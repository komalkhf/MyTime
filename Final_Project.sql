-- Junyeon
CREATE DATABASE final_project;

-- Import dataset into final_project DB with name employee_payroll_pto

-- Komal
ALTER TABLE employee_payroll_pto
ADD COLUMN employee_name VARCHAR(100);

-- Grant
-- URL for COALESCE fucntion: https://www.w3schools.com/sql/func_sqlserver_coalesce.asp
UPDATE employee_payroll_pto
SET employee_name = CONCAT(first_name, ' ', COALESCE(middle_init, ''), ' ', last_name);

-- Komal
CREATE TABLE IF NOT EXISTS employees(
employee_id VARCHAR(50) PRIMARY KEY, -- UNIQUE and Not NULL
employee_name VARCHAR(100) NOT NULL
);

-- Komal
-- URL for INSERT IGNORE statement: https://www.mysqltutorial.org/mysql-basics/mysql-insert-ingore/
INSERT IGNORE INTO Employees (employee_id, employee_name)
SELECT DISTINCT Employee_Identifier, employee_name
FROM EMPLOYEE_PAYROLL_pto;

-- Junyeon
CREATE TABLE IF NOT EXISTS job (
    job_code INT primary key,
    job_title VARCHAR(100)
);

-- Junyeon
INSERT IGNORE INTO job (job_Code,job_title)
SELECT DISTINCT job_Code,job_title
FROM EMPLOYEE_PAYROLL_pto;

-- Junyeon
CREATE TABLE IF NOT EXISTS employee_job (
    employee_id VARCHAR(50),
    job_code INT
);

-- Junyeon
INSERT IGNORE INTO employee_job (employee_id, job_code)
SELECT Employee_Identifier, job_Code
FROM EMPLOYEE_PAYROLL_pto;

-- Grant
ALTER TABLE employee_job
ADD CONSTRAINT fk_employee_job_employee_id
FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
ADD CONSTRAINT fk_employee_job_code
FOREIGN KEY (job_code) REFERENCES job(job_code);

-- Komal
CREATE TABLE IF NOT EXISTS office (
    office_id INT primary key,
    office_branch VARCHAR(100)
);

-- Komal
INSERT IGNORE INTO office (office_id,office_branch)
SELECT DISTINCT office,office_name
FROM EMPLOYEE_PAYROLL_pto;


-- Komal
CREATE TABLE IF NOT EXISTS department (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept VARCHAR(100)
);

-- Komal
INSERT INTO department (dept)
SELECT DISTINCT bureau
FROM EMPLOYEE_PAYROLL_pto;

-- Komal
CREATE TABLE IF NOT EXISTS POSITION (
    position_id INT PRIMARY KEY,
    employee_id VARCHAR(50),
    dept_id INT,
    job_code INT,
    office_id INT
);

-- Junyeon
ALTER TABLE employee_payroll_pto
ADD COLUMN dept_id int;

-- Junyeon
UPDATE employee_payroll_pto
SET dept_id = (
    SELECT dept_id
    FROM Department
    WHERE Department.dept = employee_payroll_pto.bureau
);

-- Komal
INSERT IGNORE INTO POSITION (position_id, employee_id, dept_id, job_code, office_id)
SELECT POSITION_Id, Employee_IDENTIFIER, dept_id, job_code, office
FROM EMPLOYEE_PAYROLL_PTO;

-- Grant
ALTER TABLE position
ADD CONSTRAINT fk_position_employee_id
FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
ADD CONSTRAINT fk_department_id
FOREIGN KEY (dept_id) REFERENCES department(dept_id),
ADD CONSTRAINT fk_job_code
FOREIGN KEY (job_code) REFERENCES job(job_code),
ADD CONSTRAINT fk_office_id
FOREIGN KEY (office_id) REFERENCES office(office_id);

-- Komal
CREATE TABLE Fiscal_Yr (
    year_id INT AUTO_INCREMENT PRIMARY KEY,
    fiscal_year VARCHAR(20) NOT NULL
);

-- Komal
INSERT INTO Fiscal_Yr (fiscal_year)
SELECT DISTINCT fiscal_year FROM employee_payroll_pto;

-- Komal
CREATE TABLE Fiscal_Qtr (
    quarter_id VARCHAR(2) PRIMARY KEY,
    fiscal_quarter VARCHAR(20) NOT NULL
);

-- Komal
INSERT INTO Fiscal_qtr (quarter_id, fiscal_quarter) VALUES
('Q1', '1'),
('Q2', '2'),
('Q3', '3'),
('Q4', '4');

-- Komal
ALTER TABLE employee_payroll_pto
ADD COLUMN year_id INT,
ADD COLUMN quarter_id VARCHAR(2);

-- Grant
UPDATE employee_payroll_pto
JOIN Fiscal_Yr ON employee_payroll_pto.Fiscal_Year = Fiscal_Yr.fiscal_year
JOIN Fiscal_Qtr ON employee_payroll_pto.Fiscal_Quarter = Fiscal_Qtr.fiscal_quarter
SET employee_payroll_pto.year_id = Fiscal_Yr.year_id,
    employee_payroll_pto.quarter_id = Fiscal_Qtr.quarter_id;

-- Komal
CREATE TABLE IF NOT EXISTS salary (
    employee_id VARCHAR(50),
    year_id int,
    quarter_id VARCHAR(20),
    Base_Pay DECIMAL(10, 2),
    Hrly_rate DECIMAL(10, 2)
);

-- Komal
INSERT IGNORE INTO salary (employee_id, year_id, quarter_id, Base_Pay)
SELECT employee_identifier, year_id, quarter_id, Base_Pay
FROM employee_payroll_pto;

-- Komal
UPDATE salary
SET Hrly_rate = Base_Pay / 2080;

-- Grant
ALTER TABLE salary
ADD CONSTRAINT fk_employee_id
FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
ADD CONSTRAINT fk_year_id
FOREIGN KEY (year_id) REFERENCES Fiscal_Yr(year_id),
ADD CONSTRAINT fk_quarter_id
FOREIGN KEY (quarter_id) REFERENCES Fiscal_Qtr(quarter_id);

-- Junyeon
CREATE TABLE IF NOT EXISTS employee_pto (
    employee_id VARCHAR(50),
    Original_Hire_Date DATE,
    Days_Worked INT,
    PTO_Allotted INT,
    PTO_Taken INT,
    PTO_Available INT
);

-- Grant
-- URL for STR_TO_DATE function: https://www.w3schools.com/mysql/func_mysql_str_to_date.asp
-- URL for ON DUPLICATE KEY UPDATE: https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html
INSERT INTO employee_pto (employee_id, Original_Hire_Date)
SELECT 
    COALESCE(employee_payroll_pto.employee_identifier, 'Unknown'), 
    STR_TO_DATE(employee_payroll_pto.Original_Hire_Date, '%m/%d/%Y')
FROM employee_payroll_pto
ON DUPLICATE KEY UPDATE Original_Hire_Date = STR_TO_DATE(employee_payroll_pto.Original_Hire_Date, '%m/%d/%Y');

-- Komal
-- URL for DATEDIFF function: https://www.w3schools.com/mysql/func_mysql_datediff.asp
UPDATE employee_pto 
SET Days_Worked = DATEDIFF(CURDATE(), Original_Hire_Date)
WHERE employee_id IS NOT NULL;

-- Grant
-- URL for CASE statement: https://dev.mysql.com/doc/refman/8.0/en/case.html
UPDATE employee_pto
SET PTO_Allotted = CASE
                        WHEN days_worked < 364 THEN 14
                        WHEN days_worked >= 364 AND days_worked <= 1460 THEN 21
                        ELSE 28
                    END;

-- Grant
UPDATE employee_pto
SET PTO_Taken = COALESCE(PTO_Taken, 0);

-- Grant
UPDATE employee_pto
SET PTO_Available = PTO_Allotted - PTO_Taken;

-- Grant
ALTER TABLE employee_pto
ADD CONSTRAINT fk_pto_employee_id
FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE EMPLOYEE_PTO
ADD COLUMN PTO_START varchar(50);


ALTER TABLE EMPLOYEE_PTO
ADD COLUMN PTO_end varchar(50);


CREATE VIEW final_project.VW_SHOWPAGE as 
SELECT distinct 
a.employee_name as Name, d.dept as Department, o.office_branch as Office_Branch,
t.pto_allotted, t.pto_available, 
 -- using JOIN
t.PTO_start, t.PTO_end -- Need to be created
FROM employees a 
LEFT JOIN EMPLOYEE_PTO t ON 
a.employee_id = t.employee_id
LEFT JOIN POSITION p ON 
a.employee_id = p.employee_id
LEFT JOIN department d ON 
d.dept_id = p.dept_id
LEFT JOIN office o ON 
o.office_id = p.office_id
;


UPDATE employee_pto 
set PTO_start = '2024-04-01'
where employee_id = '6ac7ba3e-d286-44f5-87a0-191dc415e23c'


UPDATE employee_pto 
set pto_start = '2024-04-30'
where employee_id in (
'7c38291b-51d4-48d8-b79e-4c445a84c410',
'e9a92ee0-120f-41f3-b824-4e4d7c43cc5c',
'd40d6826-1e92-4d7c-9602-b3eaf5f1d2e6',
'316c368f-2e09-4d00-8b54-1eda34b2c044',
'433c0c09-b58e-45c0-96ee-1cf5c315cf5f');

UPDATE employee_pto 
set pto_end = '2024-05-31'
where employee_id in (
'7c38291b-51d4-48d8-b79e-4c445a84c410',
'e9a92ee0-120f-41f3-b824-4e4d7c43cc5c',
'd40d6826-1e92-4d7c-9602-b3eaf5f1d2e6',
'316c368f-2e09-4d00-8b54-1eda34b2c044',
'433c0c09-b58e-45c0-96ee-1cf5c315cf5f');

