/**
* You can copy, modify, distribute and perform the work, even for commercial purposes, 
* all without asking permission. 
* 
* @Author: Andrii Mazur
*/

IF DB_ID('hr') IS NOT NULL
   print 'db exists, dropping it'
   use master;
   drop database hr;

CREATE DATABASE hr;

USE hr;

/* *************************************************************** 
***************************CREATING TABLES************************
**************************************************************** */
CREATE TABLE regions (
	region_id INT NOT NULL,
	region_name VARCHAR(25),
	PRIMARY KEY (region_id)
	);

CREATE TABLE countries (
	country_id CHAR(2) NOT NULL,
	country_name VARCHAR(40),
	region_id INT NOT NULL,
	PRIMARY KEY (country_id)
);

CREATE TABLE locations (
	location_id INT NOT NULL,
	street_address VARCHAR(40),
	postal_code VARCHAR(12),
	city VARCHAR(30) NOT NULL,
	state_province VARCHAR(25),
	country_id CHAR(2) NOT NULL,
	PRIMARY KEY (location_id)
	);

CREATE TABLE departments (
	department_id INT NOT NULL,
	department_name VARCHAR(30) NOT NULL,
	manager_id INT,
	location_id INT,
	PRIMARY KEY (department_id)
	);

CREATE TABLE jobs (
	job_id VARCHAR(10) NOT NULL,
	job_title VARCHAR(35) NOT NULL,
	min_salary DECIMAL(8, 0),
	max_salary DECIMAL(8, 0),
	PRIMARY KEY (job_id)
	);

CREATE TABLE employees (
	employee_id INT NOT NULL,
	first_name VARCHAR(20),
	last_name VARCHAR(25) NOT NULL,
	email VARCHAR(25) NOT NULL,
	phone_number VARCHAR(20),
	hire_date DATE NOT NULL,
	job_id VARCHAR(10) NOT NULL,
	salary DECIMAL(8, 2) NOT NULL,
	commission_pct DECIMAL(2, 2),
	manager_id INT ,
	department_id INT,
	PRIMARY KEY (employee_id)
	);

CREATE TABLE job_history (
	employee_id INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	job_id VARCHAR(10) NOT NULL,
	department_id INT NOT NULL
	);
GO
