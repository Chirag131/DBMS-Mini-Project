-- ============================================================================
--  SMART ENERGY METERING SYSTEM — Complete Database Script
--  Based on ER Diagram (6 Entities, 5 Relationships)
-- ============================================================================

-- ----------------------------------------------------------------------------
--  DATABASE CREATION
-- ----------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS smart_energy_db;
USE smart_energy_db;


-- ============================================================================
--  TABLE DEFINITIONS (following ER Diagram entity order)
-- ============================================================================

-- ----------------------------------------------------------------------------
--  1. REGION
--     Represents geographical regions served by the energy provider.
--     Attributes: Region_ID (PK), RegionName
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS region (
    region_id    INT AUTO_INCREMENT PRIMARY KEY,
    region_name  VARCHAR(60) NOT NULL
);


-- ----------------------------------------------------------------------------
--  2. TRANSFORMERS
--     Electrical transformers installed across regions.
--     Attributes: Transformer_ID (PK), Location, CapacityKW
--     Relationship: Located_in → Region (M:1)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS transformers (
    transformer_id  INT AUTO_INCREMENT PRIMARY KEY,
    location        VARCHAR(100),
    capacity_kw     DECIMAL(10,2),
    region_id       INT,
    FOREIGN KEY (region_id) REFERENCES region(region_id)
);


-- ----------------------------------------------------------------------------
--  3. CONSUMER
--     Customers who consume electricity.
--     Attributes: Consumer_ID (PK), Name, Address, PhoneNo
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS consumer (
    consumer_id  INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    address      TEXT,
    phone_no     VARCHAR(15)
);


-- ----------------------------------------------------------------------------
--  4. METER
--     Smart meters installed at consumer premises.
--     Attributes: Meter_ID (PK), InstallationDate, Status
--     Relationship: Owns ← Consumer (M:1)
--     Relationship: Supplies ← Transformers (M:1)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS meter (
    meter_id          INT AUTO_INCREMENT PRIMARY KEY,
    installation_date DATE,
    status            VARCHAR(20) DEFAULT 'active',
    consumer_id       INT,
    transformer_id    INT,
    FOREIGN KEY (consumer_id)    REFERENCES consumer(consumer_id),
    FOREIGN KEY (transformer_id) REFERENCES transformers(transformer_id)
);


-- ----------------------------------------------------------------------------
--  5. READING
--     Energy readings captured by meters.
--     Attributes: Reading_ID (PK), Current, Voltage, Energy_kWh
--     Additional (from notes): Timestamp, Frequency
--     Relationship: Generates ← Meter (M:1)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS reading (
    reading_id         INT AUTO_INCREMENT PRIMARY KEY,
    meter_id           INT,
    reading_timestamp  DATETIME,
    voltage            DECIMAL(8,2),
    current_amp        DECIMAL(8,2),
    energy_kwh         DECIMAL(10,2),
    frequency          DECIMAL(5,2) DEFAULT 50.00,
    FOREIGN KEY (meter_id) REFERENCES meter(meter_id)
);


-- ----------------------------------------------------------------------------
--  6. BILLING
--     Bills generated for consumers based on meter readings.
--     Attributes: Bill_ID (PK), BillingMonth, DueDate, FineAmt, TotalAmt
--     Relationship: Relates → Consumer (M:1)
--     Relationship: Linked → Meter (M:1)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS billing (
    bill_id        INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id    INT,
    meter_id       INT,
    billing_month  VARCHAR(20),
    units_consumed DECIMAL(10,2),
    total_amount   DECIMAL(10,2),
    fine_amt       DECIMAL(10,2) DEFAULT 0.00,
    due_date       DATE,
    status         VARCHAR(20) DEFAULT 'unpaid',
    FOREIGN KEY (consumer_id) REFERENCES consumer(consumer_id),
    FOREIGN KEY (meter_id)    REFERENCES meter(meter_id)
);


-- ============================================================================
--  SAMPLE DATA
-- ============================================================================

-- ----------------------------------------------------------------------------
--  REGION DATA
-- ----------------------------------------------------------------------------

INSERT INTO region (region_name) VALUES
('Chandigarh North'),
('Chandigarh South'),
('Mohali'),
('Patiala'),
('Ludhiana'),
('Jalandhar'),
('Amritsar');


-- ----------------------------------------------------------------------------
--  TRANSFORMERS DATA
-- ----------------------------------------------------------------------------

INSERT INTO transformers (location, capacity_kw, region_id) VALUES
('Sector 17 Substation, Chandigarh',   500.00,  1),
('Sector 35 Substation, Chandigarh',   750.00,  2),
('Phase 7 Grid, Mohali',              1000.00,  3),
('Model Town Distribution, Patiala',   400.00,  4),
('Industrial Area Hub, Ludhiana',     2000.00,  5),
('Civil Lines Grid, Jalandhar',        600.00,  6),
('Green Avenue Substation, Amritsar',  500.00,  7),
('Sector 22 Substation, Chandigarh',   800.00,  1),
('Phase 2 Industrial Grid, Mohali',   1500.00,  3),
('Main Market Substation, Ludhiana',   900.00,  5);


-- ----------------------------------------------------------------------------
--  CONSUMER DATA
-- ----------------------------------------------------------------------------

INSERT INTO consumer (name, address, phone_no) VALUES
('Rahul Sharma',   '123, Sector 17, Chandigarh',       '9876543210'),
('Priya Singh',    '45, Model Town, Patiala',           '9876543211'),
('Amit Verma',     'Shop 12, Main Market, Ludhiana',    '9876543212'),
('Neha Gupta',     '78, Civil Lines, Jalandhar',        '9876543213'),
('Rajesh Kumar',   'Plot 5, Industrial Area, Mohali',   '9876543214'),
('Simran Kaur',    '22, Phase 7, Mohali',               '9876543215'),
('Vikram Joshi',   '91, Sector 22, Chandigarh',         '9876543216'),
('Ananya Patel',   '34, Green Avenue, Amritsar',        '9876543217'),
('Karan Dhillon',  'Factory Road, Phase 2, Ludhiana',   '9876543218'),
('Pooja Rani',     '56, Sector 35, Chandigarh',         '9876543219');


-- ----------------------------------------------------------------------------
--  METER DATA
-- ----------------------------------------------------------------------------

INSERT INTO meter (installation_date, status, consumer_id, transformer_id) VALUES
('2022-01-15', 'active',  1, 1),
('2021-06-20', 'active',  2, 4),
('2020-03-10', 'active',  3, 10),
('2023-02-28', 'active',  4, 6),
('2019-11-05', 'active',  5, 9),
('2023-08-14', 'faulty',  6, 3),
('2021-12-01', 'active',  7, 8),
('2022-07-19', 'active',  8, 7),
('2020-09-22', 'active',  9, 5),
('2024-01-10', 'active', 10, 2);


-- ----------------------------------------------------------------------------
--  READING DATA
-- ----------------------------------------------------------------------------

INSERT INTO reading (meter_id, reading_timestamp, voltage, current_amp, energy_kwh, frequency) VALUES
(1,  '2026-03-01 10:00:00', 230.50,  4.20,  250.50,  50.02),
(2,  '2026-03-01 10:30:00', 228.00,  3.10,  180.00,  49.98),
(3,  '2026-03-01 11:00:00', 415.00, 12.50, 1500.75,  50.01),
(4,  '2026-03-01 11:30:00', 231.00,  2.80,  120.00,  50.00),
(5,  '2026-03-01 12:00:00', 410.00, 45.00, 5200.00,  49.95),
(6,  '2026-03-02 09:00:00', 225.00,  3.50,  200.00,  50.03),
(7,  '2026-03-02 09:30:00', 420.00,  8.90,  890.25,  50.00),
(8,  '2026-03-02 10:00:00', 229.50,  3.00,  175.00,  49.99),
(9,  '2026-03-02 10:30:00', 412.00, 40.00, 4800.00,  49.97),
(10, '2026-03-02 11:00:00', 232.00,  1.50,   95.00,  50.01),
(1,  '2026-04-01 10:00:00', 231.00,  5.00,  300.00,  50.00),
(2,  '2026-04-01 10:30:00', 227.50,  3.30,  195.00,  49.99),
(3,  '2026-04-01 11:00:00', 416.00, 13.00, 1620.00,  50.02),
(5,  '2026-04-01 12:00:00', 411.00, 47.00, 5450.00,  49.96),
(7,  '2026-04-02 09:30:00', 418.00,  9.20,  920.00,  50.01);


-- ----------------------------------------------------------------------------
--  BILLING DATA
-- ----------------------------------------------------------------------------

INSERT INTO billing (consumer_id, meter_id, billing_month, units_consumed, total_amount, fine_amt, due_date, status) VALUES
(1,  1,  'March 2026',  250.50,  1377.75,     0.00, '2026-03-20', 'paid'),
(2,  2,  'March 2026',  180.00,   990.00,     0.00, '2026-03-20', 'paid'),
(3,  3,  'March 2026', 1500.75, 17333.67,     0.00, '2026-03-21', 'unpaid'),
(4,  4,  'March 2026',  120.00,   660.00,     0.00, '2026-03-21', 'paid'),
(5,  5,  'March 2026', 5200.00, 48620.00,  2431.00, '2026-03-22', 'overdue'),
(6,  6,  'March 2026',  200.00,  1100.00,     0.00, '2026-03-22', 'unpaid'),
(7,  7,  'March 2026',  890.25, 10282.39,     0.00, '2026-03-23', 'paid'),
(8,  8,  'March 2026',  175.00,   962.50,     0.00, '2026-03-23', 'unpaid'),
(9,  9,  'March 2026', 4800.00, 44880.00,  2244.00, '2026-03-24', 'overdue'),
(10, 10, 'March 2026',   95.00,   365.75,     0.00, '2026-03-24', 'paid'),
(1,  1,  'April 2026',  300.00,  1650.00,     0.00, '2026-04-20', 'unpaid'),
(2,  2,  'April 2026',  195.00,  1072.50,     0.00, '2026-04-20', 'unpaid');


-- ============================================================================
--  VIEWS
--  (Applications do not directly depend on physical table structure,
--   they use Views — as noted in ER diagram documentation)
-- ============================================================================

-- ----------------------------------------------------------------------------
--  VIEW 1: consumer_bill_summary
--  Quick overview of each consumer's billing details.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW consumer_bill_summary AS
SELECT
    c.consumer_id,
    c.name            AS consumer_name,
    c.phone_no,
    b.billing_month,
    b.units_consumed,
    b.total_amount,
    b.fine_amt,
    b.status          AS bill_status
FROM consumer c
JOIN billing b ON c.consumer_id = b.consumer_id
ORDER BY c.consumer_id, b.billing_month;


-- ----------------------------------------------------------------------------
--  VIEW 2: overdue_bills_view
--  Lists all overdue bills with days past due date.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW overdue_bills_view AS
SELECT
    c.consumer_id,
    c.name                            AS consumer_name,
    c.phone_no,
    b.bill_id,
    b.billing_month,
    b.total_amount,
    b.fine_amt,
    b.due_date,
    DATEDIFF(CURDATE(), b.due_date)   AS days_overdue
FROM consumer c
JOIN billing b ON c.consumer_id = b.consumer_id
WHERE b.status = 'overdue'
ORDER BY days_overdue DESC;


-- ----------------------------------------------------------------------------
--  VIEW 3: meter_health_view
--  Shows meters that are NOT active, with consumer contact info.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW meter_health_view AS
SELECT
    m.meter_id,
    m.status                                  AS meter_status,
    m.installation_date,
    DATEDIFF(CURDATE(), m.installation_date)  AS days_since_install,
    c.name                                    AS consumer_name,
    c.phone_no,
    t.location                                AS transformer_location
FROM meter m
JOIN consumer c     ON m.consumer_id    = c.consumer_id
JOIN transformers t ON m.transformer_id = t.transformer_id
WHERE m.status != 'active';


-- ----------------------------------------------------------------------------
--  VIEW 4: monthly_consumption_report
--  Detailed monthly energy consumption per consumer.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW monthly_consumption_report AS
SELECT
    c.consumer_id,
    c.name              AS consumer_name,
    m.meter_id,
    r.reading_timestamp,
    r.voltage,
    r.current_amp,
    r.energy_kwh,
    r.frequency
FROM consumer c
JOIN meter m   ON c.consumer_id = m.consumer_id
JOIN reading r ON m.meter_id    = r.meter_id
ORDER BY r.reading_timestamp DESC;


-- ----------------------------------------------------------------------------
--  VIEW 5: transformer_load_view
--  Shows each transformer with total meters connected and region info.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW transformer_load_view AS
SELECT
    t.transformer_id,
    t.location,
    t.capacity_kw,
    rg.region_name,
    COUNT(m.meter_id)          AS meters_connected,
    COALESCE(SUM(r.energy_kwh), 0) AS total_energy_kwh
FROM transformers t
JOIN region rg ON t.region_id = rg.region_id
LEFT JOIN meter m ON m.transformer_id = t.transformer_id
LEFT JOIN reading r ON r.meter_id = m.meter_id
GROUP BY t.transformer_id, t.location, t.capacity_kw, rg.region_name
ORDER BY total_energy_kwh DESC;


-- ----------------------------------------------------------------------------
--  VIEW 6: region_summary_view
--  Region-wise summary of transformers, meters and total consumption.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW region_summary_view AS
SELECT
    rg.region_id,
    rg.region_name,
    COUNT(DISTINCT t.transformer_id)   AS total_transformers,
    COUNT(DISTINCT m.meter_id)         AS total_meters,
    COALESCE(SUM(r.energy_kwh), 0)     AS total_energy_kwh
FROM region rg
LEFT JOIN transformers t ON rg.region_id = t.region_id
LEFT JOIN meter m        ON t.transformer_id = m.transformer_id
LEFT JOIN reading r      ON m.meter_id = r.meter_id
GROUP BY rg.region_id, rg.region_name
ORDER BY total_energy_kwh DESC;


-- ============================================================================
--  STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
--  PROCEDURE 1: add_new_consumer
--  Registers a new consumer and installs a meter linked to a transformer.
-- ----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE add_new_consumer(
    IN p_name           VARCHAR(100),
    IN p_address        TEXT,
    IN p_phone_no       VARCHAR(15),
    IN p_transformer_id INT
)
BEGIN
    DECLARE v_consumer_id INT;

    INSERT INTO consumer (name, address, phone_no)
    VALUES (p_name, p_address, p_phone_no);

    SET v_consumer_id = LAST_INSERT_ID();

    INSERT INTO meter (installation_date, status, consumer_id, transformer_id)
    VALUES (CURDATE(), 'active', v_consumer_id, p_transformer_id);

    SELECT v_consumer_id AS new_consumer_id, LAST_INSERT_ID() AS new_meter_id;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
--  PROCEDURE 2: record_reading
--  Records a new energy reading for a given meter.
-- ----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE record_reading(
    IN p_meter_id    INT,
    IN p_voltage     DECIMAL(8,2),
    IN p_current_amp DECIMAL(8,2),
    IN p_energy_kwh  DECIMAL(10,2),
    IN p_frequency   DECIMAL(5,2)
)
BEGIN
    INSERT INTO reading (meter_id, reading_timestamp, voltage, current_amp, energy_kwh, frequency)
    VALUES (p_meter_id, NOW(), p_voltage, p_current_amp, p_energy_kwh, p_frequency);

    SELECT LAST_INSERT_ID() AS new_reading_id;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
--  PROCEDURE 3: generate_bill
--  Generates a bill for a consumer based on meter reading.
-- ----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE generate_bill(
    IN p_consumer_id   INT,
    IN p_meter_id      INT,
    IN p_units         DECIMAL(10,2),
    IN p_billing_month VARCHAR(20)
)
BEGIN
    DECLARE v_rate        DECIMAL(6,2);
    DECLARE v_total       DECIMAL(10,2);

    -- Simple slab-based rate calculation
    IF p_units <= 100 THEN
        SET v_rate = 3.50;
    ELSEIF p_units <= 300 THEN
        SET v_rate = 5.00;
    ELSEIF p_units <= 1000 THEN
        SET v_rate = 7.50;
    ELSE
        SET v_rate = 8.50;
    END IF;

    SET v_total = ROUND(p_units * v_rate * 1.10, 2);   -- 10% tax included

    INSERT INTO billing (consumer_id, meter_id, billing_month, units_consumed, total_amount, fine_amt, due_date, status)
    VALUES (p_consumer_id, p_meter_id, p_billing_month, p_units, v_total, 0.00,
            DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'unpaid');

    SELECT LAST_INSERT_ID() AS new_bill_id, v_total AS bill_amount;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
--  PROCEDURE 4: mark_overdue_bills
--  Marks unpaid bills past their due date as overdue and applies 5% fine.
-- ----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE mark_overdue_bills()
BEGIN
    UPDATE billing
    SET status   = 'overdue',
        fine_amt = ROUND(total_amount * 0.05, 2)
    WHERE status = 'unpaid'
      AND due_date < CURDATE();

    SELECT ROW_COUNT() AS bills_marked_overdue;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
--  PROCEDURE 5: pay_bill
--  Records payment for a bill and marks it as paid.
-- ----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE pay_bill(
    IN p_bill_id INT
)
BEGIN
    UPDATE billing
    SET status = 'paid'
    WHERE bill_id = p_bill_id;

    SELECT p_bill_id AS paid_bill_id, 'success' AS payment_status;
END //

DELIMITER ;


-- ----------------------------------------------------------------------------
--  PROCEDURE 6: get_consumer_details
--  Fetches complete details of a consumer with meter and latest reading.
-- ----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE get_consumer_details(
    IN p_consumer_id INT
)
BEGIN
    SELECT
        c.consumer_id,
        c.name,
        c.address,
        c.phone_no,
        m.meter_id,
        m.installation_date,
        m.status          AS meter_status,
        t.location        AS transformer_location,
        t.capacity_kw,
        rg.region_name
    FROM consumer c
    JOIN meter m        ON c.consumer_id    = m.consumer_id
    JOIN transformers t ON m.transformer_id = t.transformer_id
    JOIN region rg      ON t.region_id      = rg.region_id
    WHERE c.consumer_id = p_consumer_id;

    SELECT
        r.reading_id,
        r.reading_timestamp,
        r.voltage,
        r.current_amp,
        r.energy_kwh,
        r.frequency
    FROM reading r
    JOIN meter m ON r.meter_id = m.meter_id
    WHERE m.consumer_id = p_consumer_id
    ORDER BY r.reading_timestamp DESC
    LIMIT 5;

    SELECT
        b.bill_id,
        b.billing_month,
        b.units_consumed,
        b.total_amount,
        b.fine_amt,
        b.due_date,
        b.status
    FROM billing b
    WHERE b.consumer_id = p_consumer_id
    ORDER BY b.due_date DESC;
END //

DELIMITER ;


-- ============================================================================
--  SAMPLE QUERIES
-- ============================================================================

-- Q1: List all consumers with their meter and transformer details
SELECT
    c.consumer_id,
    c.name,
    c.phone_no,
    m.meter_id,
    m.status         AS meter_status,
    t.location       AS transformer_location,
    t.capacity_kw
FROM consumer c
JOIN meter m        ON c.consumer_id    = m.consumer_id
JOIN transformers t ON m.transformer_id = t.transformer_id;


-- Q2: Find all unpaid and overdue bills
SELECT
    b.bill_id,
    c.name           AS consumer,
    b.billing_month,
    b.total_amount,
    b.fine_amt,
    b.due_date,
    b.status
FROM billing b
JOIN consumer c ON b.consumer_id = c.consumer_id
WHERE b.status IN ('unpaid', 'overdue')
ORDER BY b.due_date;


-- Q3: Top 5 consumers by total energy consumption
SELECT
    c.name           AS consumer,
    SUM(r.energy_kwh) AS total_kwh
FROM reading r
JOIN meter m    ON r.meter_id    = m.meter_id
JOIN consumer c ON m.consumer_id = c.consumer_id
GROUP BY c.consumer_id, c.name
ORDER BY total_kwh DESC
LIMIT 5;


-- Q4: Region-wise total energy consumption
SELECT
    rg.region_name,
    COUNT(DISTINCT m.meter_id)         AS total_meters,
    COALESCE(SUM(r.energy_kwh), 0)     AS total_kwh
FROM region rg
LEFT JOIN transformers t ON rg.region_id      = t.region_id
LEFT JOIN meter m        ON t.transformer_id  = m.transformer_id
LEFT JOIN reading r      ON m.meter_id        = r.meter_id
GROUP BY rg.region_id, rg.region_name
ORDER BY total_kwh DESC;


-- Q5: Transformers nearing capacity (total consumption > 80% of capacity)
SELECT
    t.transformer_id,
    t.location,
    t.capacity_kw,
    COALESCE(SUM(r.energy_kwh), 0)                           AS total_load_kwh,
    ROUND(COALESCE(SUM(r.energy_kwh), 0) / t.capacity_kw * 100, 2) AS load_percent
FROM transformers t
LEFT JOIN meter m   ON t.transformer_id = m.transformer_id
LEFT JOIN reading r ON m.meter_id       = r.meter_id
GROUP BY t.transformer_id, t.location, t.capacity_kw
HAVING load_percent > 80
ORDER BY load_percent DESC;


-- Q6: Consumers with bills above average
SELECT
    c.name           AS consumer,
    b.total_amount,
    b.billing_month
FROM billing b
JOIN consumer c ON b.consumer_id = c.consumer_id
WHERE b.total_amount > (
    SELECT AVG(total_amount) FROM billing
)
ORDER BY b.total_amount DESC;


-- Q7: Monthly revenue summary
SELECT
    billing_month,
    COUNT(*)                   AS total_bills,
    SUM(total_amount)          AS total_billed,
    SUM(fine_amt)              AS total_fines,
    SUM(CASE WHEN status = 'paid' THEN total_amount ELSE 0 END)    AS collected,
    SUM(CASE WHEN status != 'paid' THEN total_amount ELSE 0 END)   AS outstanding
FROM billing
GROUP BY billing_month;


-- Q8: Faulty meters with consumer info
SELECT * FROM meter_health_view;


-- Q9: Overdue bills report
SELECT * FROM overdue_bills_view;


-- Q10: Transformer load distribution
SELECT * FROM transformer_load_view;


-- Sample procedure calls
-- CALL add_new_consumer('Deepak Mehta', '101, Sector 44, Chandigarh', '9900000001', 1);
-- CALL record_reading(1, 231.00, 5.20, 310.00, 50.01);
-- CALL generate_bill(1, 1, 310.00, 'May 2026');
-- CALL mark_overdue_bills();
-- CALL pay_bill(3);
-- CALL get_consumer_details(1);


-- ============================================================================
--  END OF SCRIPT
-- ============================================================================
