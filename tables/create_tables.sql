CREATE DATABASE IF NOT EXISTS smart_energy_db;
USE smart_energy_db;

CREATE TABLE IF NOT EXISTS customers (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_no VARCHAR(15),
    address TEXT,
    city VARCHAR(40),
    state VARCHAR(40) DEFAULT 'Punjab',
    pincode VARCHAR(10),
    meter_number VARCHAR(30) UNIQUE,
    connection_type ENUM('domestic', 'commercial', 'industrial') DEFAULT 'domestic',
    connection_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS meters (
    meter_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_number VARCHAR(30) NOT NULL,
    meter_type VARCHAR(30),
    manufacturer VARCHAR(50),
    install_date DATE,
    last_reading_date DATE,
    status VARCHAR(20) DEFAULT 'working',
    cust_id INT,
    location VARCHAR(100),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TABLE IF NOT EXISTS energy_readings (
    reading_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_id INT,
    cust_id INT,
    reading_date DATETIME,
    units_consumed DECIMAL(10,2),
    previous_reading DECIMAL(10,2),
    current_reading DECIMAL(10,2),
    reading_type VARCHAR(20) DEFAULT 'monthly',
    recorded_by VARCHAR(50),
    FOREIGN KEY (meter_id) REFERENCES meters(meter_id),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TABLE IF NOT EXISTS tariff_plan (
    tariff_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50),
    connection_type ENUM('domestic', 'commercial', 'industrial'),
    min_units INT,
    max_units INT,
    rate_per_unit DECIMAL(6,2),
    fixed_charge DECIMAL(8,2) DEFAULT 0.00,
    effective_from DATE,
    effective_to DATE
);

CREATE TABLE IF NOT EXISTS bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT,
    meter_id INT,
    billing_month VARCHAR(20),
    bill_date DATE,
    units_consumed DECIMAL(10,2),
    amount DECIMAL(10,2),
    tax DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2),
    due_date DATE,
    status VARCHAR(20) DEFAULT 'unpaid',
    generated_by VARCHAR(50) DEFAULT 'system',
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT,
    cust_id INT,
    payment_date DATETIME,
    amount_paid DECIMAL(10,2),
    payment_mode VARCHAR(30),
    transaction_id VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'success',
    FOREIGN KEY (bill_id) REFERENCES bills(bill_id),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TABLE IF NOT EXISTS complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT,
    meter_id INT,
    complaint_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    complaint_type VARCHAR(50),
    description TEXT,
    status VARCHAR(20) DEFAULT 'open',
    resolved_date DATETIME,
    assigned_to VARCHAR(50),
    priority VARCHAR(10) DEFAULT 'medium',
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
);

CREATE TABLE IF NOT EXISTS employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(60) NOT NULL,
    designation VARCHAR(40),
    department VARCHAR(40),
    phone VARCHAR(15),
    email VARCHAR(80),
    salary DECIMAL(10,2),
    joining_date DATE,
    is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE IF NOT EXISTS areas (
    area_id INT AUTO_INCREMENT PRIMARY KEY,
    area_name VARCHAR(60),
    zone VARCHAR(30),
    city VARCHAR(40) DEFAULT 'Chandigarh',
    total_connections INT DEFAULT 0,
    area_incharge INT,
    FOREIGN KEY (area_incharge) REFERENCES employees(emp_id)
);

CREATE TABLE IF NOT EXISTS notifications (
    notif_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT,
    notif_type VARCHAR(30),
    message TEXT,
    sent_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    sent_via VARCHAR(20) DEFAULT 'sms',
    is_read TINYINT(1) DEFAULT 0,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

INSERT INTO customers (first_name, last_name, email, phone_no, address, city, state, pincode, meter_number, connection_type, connection_date) VALUES
('Rahul', 'Sharma', 'rahul.sharma@gmail.com', '9876543210', '123, Sector 17', 'Chandigarh', 'Punjab', '160017', 'MTR001', 'domestic', '2022-01-15'),
('Priya', 'Singh', 'priya.singh@yahoo.com', '9876543211', '45, Model Town', 'Patiala', 'Punjab', '147001', 'MTR002', 'domestic', '2021-06-20'),
('Amit', 'Verma', 'amit.verma@hotmail.com', '9876543212', 'Shop 12, Main Market', 'Ludhiana', 'Punjab', '141001', 'MTR003', 'commercial', '2020-03-10'),
('Neha', 'Gupta', 'neha.g@gmail.com', '9876543213', '78, Civil Lines', 'Jalandhar', 'Punjab', '144001', 'MTR004', 'domestic', '2023-02-28'),
('Rajesh', 'Kumar', 'rajesh.k@gmail.com', '9876543214', 'Plot 5, Industrial Area', 'Mohali', 'Punjab', '160055', 'MTR005', 'industrial', '2019-11-05'),
('Simran', 'Kaur', 'simran.kaur@gmail.com', '9876543215', '22, Phase 7', 'Mohali', 'Punjab', '160062', 'MTR006', 'domestic', '2023-08-14'),
('Vikram', 'Joshi', 'vikram.j@outlook.com', '9876543216', '91, Sector 22', 'Chandigarh', 'Punjab', '160022', 'MTR007', 'commercial', '2021-12-01'),
('Ananya', 'Patel', 'ananya.p@gmail.com', '9876543217', '34, Green Avenue', 'Amritsar', 'Punjab', '143001', 'MTR008', 'domestic', '2022-07-19'),
('Karan', 'Dhillon', 'karan.d@gmail.com', '9876543218', 'Factory Road, Phase 2', 'Ludhiana', 'Punjab', '141002', 'MTR009', 'industrial', '2020-09-22'),
('Pooja', 'Rani', 'pooja.r@gmail.com', '9876543219', '56, Sector 35', 'Chandigarh', 'Punjab', '160035', 'MTR010', 'domestic', '2024-01-10');

INSERT INTO meters (meter_number, meter_type, manufacturer, install_date, last_reading_date, status, cust_id, location) VALUES
('MTR001', 'smart', 'Genus Power', '2022-01-15', '2026-03-01', 'working', 1, 'Sector 17, Chandigarh'),
('MTR002', 'digital', 'HPL Electric', '2021-06-20', '2026-03-01', 'working', 2, 'Model Town, Patiala'),
('MTR003', 'smart', 'Genus Power', '2020-03-10', '2026-03-01', 'working', 3, 'Main Market, Ludhiana'),
('MTR004', 'analog', 'Secure Meters', '2023-02-28', '2026-03-01', 'working', 4, 'Civil Lines, Jalandhar'),
('MTR005', 'smart', 'Genus Power', '2019-11-05', '2026-03-01', 'working', 5, 'Industrial Area, Mohali'),
('MTR006', 'digital', 'HPL Electric', '2023-08-14', '2026-03-01', 'faulty', 6, 'Phase 7, Mohali'),
('MTR007', 'smart', 'Secure Meters', '2021-12-01', '2026-03-01', 'working', 7, 'Sector 22, Chandigarh'),
('MTR008', 'analog', 'L&T', '2022-07-19', '2026-03-01', 'working', 8, 'Green Avenue, Amritsar'),
('MTR009', 'smart', 'Genus Power', '2020-09-22', '2026-03-01', 'working', 9, 'Factory Road, Ludhiana'),
('MTR010', 'digital', 'HPL Electric', '2024-01-10', '2026-03-01', 'working', 10, 'Sector 35, Chandigarh');

INSERT INTO energy_readings (meter_id, cust_id, reading_date, units_consumed, previous_reading, current_reading, reading_type, recorded_by) VALUES
(1, 1, '2026-03-01 10:00:00', 250.50, 1200.00, 1450.50, 'monthly', 'Ramesh'),
(2, 2, '2026-03-01 10:30:00', 180.00, 800.00, 980.00, 'monthly', 'Ramesh'),
(3, 3, '2026-03-01 11:00:00', 1500.75, 5000.00, 6500.75, 'monthly', 'Suresh'),
(4, 4, '2026-03-01 11:30:00', 120.00, 450.00, 570.00, 'monthly', 'Ramesh'),
(5, 5, '2026-03-01 12:00:00', 5200.00, 20000.00, 25200.00, 'monthly', 'Suresh'),
(6, 6, '2026-03-02 09:00:00', 200.00, 300.00, 500.00, 'monthly', 'Mukesh'),
(7, 7, '2026-03-02 09:30:00', 890.25, 3000.00, 3890.25, 'monthly', 'Mukesh'),
(8, 8, '2026-03-02 10:00:00', 175.00, 600.00, 775.00, 'monthly', 'Ramesh'),
(9, 9, '2026-03-02 10:30:00', 4800.00, 18000.00, 22800.00, 'monthly', 'Suresh'),
(10, 10, '2026-03-02 11:00:00', 95.00, 100.00, 195.00, 'monthly', 'Mukesh');

INSERT INTO tariff_plan (plan_name, connection_type, min_units, max_units, rate_per_unit, fixed_charge, effective_from, effective_to) VALUES
('Domestic Basic', 'domestic', 0, 100, 3.50, 50.00, '2026-01-01', '2026-12-31'),
('Domestic Standard', 'domestic', 101, 300, 5.00, 100.00, '2026-01-01', '2026-12-31'),
('Domestic Premium', 'domestic', 301, 9999, 7.50, 150.00, '2026-01-01', '2026-12-31'),
('Commercial Basic', 'commercial', 0, 500, 8.00, 300.00, '2026-01-01', '2026-12-31'),
('Commercial Heavy', 'commercial', 501, 9999, 10.50, 500.00, '2026-01-01', '2026-12-31'),
('Industrial Light', 'industrial', 0, 2000, 6.50, 1000.00, '2026-01-01', '2026-12-31'),
('Industrial Heavy', 'industrial', 2001, 99999, 8.50, 2000.00, '2026-01-01', '2026-12-31');

INSERT INTO bills (cust_id, meter_id, billing_month, bill_date, units_consumed, amount, tax, total_amount, due_date, status) VALUES
(1, 1, 'March 2026', '2026-03-05', 250.50, 1252.50, 125.25, 1377.75, '2026-03-20', 'paid'),
(2, 2, 'March 2026', '2026-03-05', 180.00, 900.00, 90.00, 990.00, '2026-03-20', 'paid'),
(3, 3, 'March 2026', '2026-03-06', 1500.75, 15757.88, 1575.79, 17333.67, '2026-03-21', 'unpaid'),
(4, 4, 'March 2026', '2026-03-06', 120.00, 600.00, 60.00, 660.00, '2026-03-21', 'paid'),
(5, 5, 'March 2026', '2026-03-07', 5200.00, 44200.00, 4420.00, 48620.00, '2026-03-22', 'overdue'),
(6, 6, 'March 2026', '2026-03-07', 200.00, 1000.00, 100.00, 1100.00, '2026-03-22', 'unpaid'),
(7, 7, 'March 2026', '2026-03-08', 890.25, 9347.63, 934.76, 10282.39, '2026-03-23', 'paid'),
(8, 8, 'March 2026', '2026-03-08', 175.00, 875.00, 87.50, 962.50, '2026-03-23', 'unpaid'),
(9, 9, 'March 2026', '2026-03-09', 4800.00, 40800.00, 4080.00, 44880.00, '2026-03-24', 'overdue'),
(10, 10, 'March 2026', '2026-03-09', 95.00, 332.50, 33.25, 365.75, '2026-03-24', 'paid');

INSERT INTO payments (bill_id, cust_id, payment_date, amount_paid, payment_mode, transaction_id, payment_status) VALUES
(1, 1, '2026-03-15 14:30:00', 1377.75, 'upi', 'TXN20260315001', 'success'),
(2, 2, '2026-03-18 16:00:00', 990.00, 'card', 'TXN20260318002', 'success'),
(4, 4, '2026-03-19 10:00:00', 660.00, 'cash', NULL, 'success'),
(7, 7, '2026-03-20 11:30:00', 10282.39, 'netbanking', 'TXN20260320003', 'success'),
(10, 10, '2026-03-22 09:00:00', 365.75, 'upi', 'TXN20260322004', 'success');

INSERT INTO employees (emp_name, designation, department, phone, email, salary, joining_date) VALUES
('Ramesh Chandra', 'Meter Reader', 'Field Operations', '9800000001', 'ramesh@energy.com', 25000.00, '2018-05-10'),
('Suresh Yadav', 'Meter Reader', 'Field Operations', '9800000002', 'suresh@energy.com', 25000.00, '2019-08-15'),
('Mukesh Pandey', 'Meter Reader', 'Field Operations', '9800000003', 'mukesh@energy.com', 22000.00, '2021-01-20'),
('Anil Kumar', 'Billing Officer', 'Billing', '9800000004', 'anil@energy.com', 35000.00, '2017-03-01'),
('Sunita Devi', 'Manager', 'Operations', '9800000005', 'sunita@energy.com', 55000.00, '2015-06-10'),
('Harpreet Singh', 'Technician', 'Maintenance', '9800000006', 'harpreet@energy.com', 30000.00, '2020-11-25');

INSERT INTO areas (area_name, zone, city, total_connections, area_incharge) VALUES
('Sector 17', 'north', 'Chandigarh', 1500, 5),
('Model Town', 'east', 'Patiala', 800, 5),
('Main Market', 'west', 'Ludhiana', 2000, 5),
('Industrial Area Phase 2', 'south', 'Mohali', 500, 5),
('Civil Lines', 'north', 'Jalandhar', 1200, 5);

INSERT INTO complaints (cust_id, meter_id, complaint_date, complaint_type, description, status, resolved_date, assigned_to, priority) VALUES
(6, 6, '2026-03-10 08:00:00', 'meter fault', 'Meter is showing wrong readings, display is flickering', 'in_progress', NULL, 'Harpreet Singh', 'high'),
(5, 5, '2026-03-12 09:30:00', 'wrong bill', 'Bill amount seems too high compared to last month usage', 'open', NULL, 'Anil Kumar', 'medium'),
(3, 3, '2026-02-20 14:00:00', 'no supply', 'Power cut for more than 24 hours in the area', 'resolved', '2026-02-21 18:00:00', 'Harpreet Singh', 'high'),
(8, 8, '2026-03-15 11:00:00', 'meter fault', 'Analog meter needle is stuck at same position', 'open', NULL, 'Harpreet Singh', 'medium');

INSERT INTO notifications (cust_id, notif_type, message, sent_via, is_read) VALUES
(1, 'bill_generated', 'Dear Rahul, your electricity bill for March 2026 is Rs.1377.75. Due date: 20-Mar-2026.', 'sms', 1),
(1, 'payment_received', 'Dear Rahul, payment of Rs.1377.75 received successfully. Thank you!', 'sms', 1),
(3, 'bill_generated', 'Dear Amit, your electricity bill for March 2026 is Rs.17333.67. Due date: 21-Mar-2026.', 'email', 0),
(5, 'due_reminder', 'Dear Rajesh, your bill of Rs.48620.00 is overdue. Please pay immediately to avoid disconnection.', 'both', 0),
(6, 'bill_generated', 'Dear Simran, your electricity bill for March 2026 is Rs.1100.00. Due date: 22-Mar-2026.', 'sms', 0),
(9, 'due_reminder', 'Dear Karan, your bill of Rs.44880.00 is overdue. Please pay immediately to avoid disconnection.', 'both', 0);
