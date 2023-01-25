--  Data is from https://github.com/vrajmohan/pgsql-sample-data/tree/master/employee
-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
  dept_no VARCHAR(4) NOT NULL,
  dept_name VARCHAR(40) NOT NULL,
  PRIMARY KEY (dept_no),
  UNIQUE (dept_name)
);

CREATE TABLE employees (
  emp_no INT NOT NULL,
  birth_date DATE NOT NULL,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  gender VARCHAR NOT NULL,
  hire_date DATE NOT NULL,
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, from_date)
);

--ok, i created new database with all this information 
--to make sure all the tables were lined up as intended here. 
-- then just ran the tables to make sure it looks good

select * from departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;

--CHALLENGE
--Retrieve the emp_no, first_name, and last_name columns from the Employees table.

SELECT emp_no, first_name, last_name
FROM employees
-- INTO retirement_titles
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')

--Retrieve the title, from_date, and to_date columns from the Titles table.

SELECT title, from_date, to_date
FROM titles
--INTO retirement_titles
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')

--joining tables on primary key which is emp_no 
--but do we include birth_date column somewhere as well? have to filter by that eventually

SELECT e.emp_no,
	   e.first_name,
	   e.last_name,
	   ti.title,
	   ti.from_date,
	   ti.to_date
INTO retirement_titles
FROM Employees as e
INNER JOIN titles as ti
	ON e.emp_no = ti.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;

SELECT * FROM retirement_titles
-- #8 of challenge
-- Use Distinct with Orderby to remove duplicate rows 
-- would i need to select to_date as well?
-- would i put ascending for emp_no at bottom or is ascending already there

SELECT DISTINCT ON (rt.emp_no) 
	rt.emp_no,
	rt.first_name,
	rt.last_name,
	rt.title
INTO unique_titles
FROM retirement_titles AS rt
WHERE rt.to_date = ('9999-01-01')
ORDER BY rt.emp_no, rt.to_date DESC;

-- #16 of challenge - writing another query 
-- #19 says sort count column - is that the title colum basically?
SELECT COUNT(ut.title),
	ut.title
-- "INTO" has to come before FROM - for.. whatever reason.. SQL
INTO retiring_titles
FROM unique_titles AS ut
GROUP BY ut.title
ORDER BY count DESC;

------- DELIVERABLE 2 - Eligibility for mentorship program 

SELECT DISTINCT ON (e.emp_no) 
	   e.emp_no,
	   e.first_name,
	   e.last_name,
	   e.birth_date,
	   de.from_date,
	   de.to_date,
	   ti.title
INTO mentorship_eligibility
FROM employees as e
INNER JOIN dept_emp as de
	ON (e.emp_no = de.emp_no)
INNER JOIN titles as ti
	ON (e.emp_no = ti.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND de.to_date = ('9999-01-01')
ORDER BY e.emp_no
