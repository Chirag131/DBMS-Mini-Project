-- ============================================================
-- Smart Energy Metering Database
-- DBMS       : MariaDB 10.6+
-- Author     : Chirag Tuteja
-- Created    : 2026-04-11
-- Description: A comprehensive database for smart energy
--              metering, billing, tariff management, and
--              real-time consumption analytics.
-- ============================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS smart_energy_metering
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE smart_energy_metering;

-- ============================================================
-- 1. REGIONS & LOCATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS regions (
    region_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    region_name     VARCHAR(100)  NOT NULL,
    state           VARCHAR(100)  NOT NULL,
    country         VARCHAR(100)  NOT NULL DEFAULT 'India',
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_region (region_name, state)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS locations (
    location_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    region_id       INT UNSIGNED  NOT NULL,
    address_line1   VARCHAR(255)  NOT NULL,
    address_line2   VARCHAR(255)  DEFAULT NULL,
    city            VARCHAR(100)  NOT NULL,
    pincode         VARCHAR(10)   NOT NULL,
    latitude        DECIMAL(10,7) DEFAULT NULL,
    longitude       DECIMAL(10,7) DEFAULT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_location_region
        FOREIGN KEY (region_id) REFERENCES regions(region_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_location_city (city),
    INDEX idx_location_pincode (pincode)
) ENGINE=InnoDB;


-- ============================================================
-- 2. ENERGY SUPPLIERS / PROVIDERS
-- ============================================================

CREATE TABLE IF NOT EXISTS energy_suppliers (
    supplier_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_name   VARCHAR(150)  NOT NULL,
    supplier_code   VARCHAR(20)   NOT NULL UNIQUE,
    contact_email   VARCHAR(255)  DEFAULT NULL,
    contact_phone   VARCHAR(20)   DEFAULT NULL,
    website         VARCHAR(255)  DEFAULT NULL,
    region_id       INT UNSIGNED  DEFAULT NULL,
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_supplier_region
        FOREIGN KEY (region_id) REFERENCES regions(region_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;


-- ============================================================
-- 3. CONSUMERS / CUSTOMERS
-- ============================================================

CREATE TABLE IF NOT EXISTS consumers (
    consumer_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(100)  NOT NULL,
    last_name       VARCHAR(100)  NOT NULL,
    email           VARCHAR(255)  NOT NULL UNIQUE,
    phone           VARCHAR(20)   NOT NULL,
    consumer_type   ENUM('RESIDENTIAL','COMMERCIAL','INDUSTRIAL','AGRICULTURAL')
                        NOT NULL DEFAULT 'RESIDENTIAL',
    location_id     INT UNSIGNED  NOT NULL,
    supplier_id     INT UNSIGNED  NOT NULL,
    account_number  VARCHAR(30)   NOT NULL UNIQUE,
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    registered_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_consumer_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_consumer_supplier
        FOREIGN KEY (supplier_id) REFERENCES energy_suppliers(supplier_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_consumer_name (last_name, first_name),
    INDEX idx_consumer_type (consumer_type)
) ENGINE=InnoDB;


-- ============================================================
-- 4. TARIFF / RATE PLANS
-- ============================================================

CREATE TABLE IF NOT EXISTS tariff_plans (
    tariff_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    plan_name       VARCHAR(150)  NOT NULL,
    plan_code       VARCHAR(20)   NOT NULL UNIQUE,
    consumer_type   ENUM('RESIDENTIAL','COMMERCIAL','INDUSTRIAL','AGRICULTURAL')
                        NOT NULL,
    supplier_id     INT UNSIGNED  NOT NULL,
    description     TEXT          DEFAULT NULL,
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    effective_from  DATE          NOT NULL,
    effective_to    DATE          DEFAULT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_tariff_supplier
        FOREIGN KEY (supplier_id) REFERENCES energy_suppliers(supplier_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_tariff_type (consumer_type),
    INDEX idx_tariff_dates (effective_from, effective_to)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS tariff_slabs (
    slab_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tariff_id       INT UNSIGNED  NOT NULL,
    min_units       DECIMAL(10,2) NOT NULL DEFAULT 0,
    max_units       DECIMAL(10,2) DEFAULT NULL,       -- NULL = unlimited
    rate_per_unit   DECIMAL(8,4)  NOT NULL,            -- INR per kWh
    fixed_charge    DECIMAL(10,2) NOT NULL DEFAULT 0,  -- fixed monthly charge for this slab
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_slab_tariff
        FOREIGN KEY (tariff_id) REFERENCES tariff_plans(tariff_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    INDEX idx_slab_range (tariff_id, min_units, max_units)
) ENGINE=InnoDB;


-- ============================================================
-- 5. SMART METERS
-- ============================================================

CREATE TABLE IF NOT EXISTS meters (
    meter_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    meter_serial    VARCHAR(50)   NOT NULL UNIQUE,
    meter_type      ENUM('SINGLE_PHASE','THREE_PHASE','PREPAID','NET_METER')
                        NOT NULL DEFAULT 'SINGLE_PHASE',
    manufacturer    VARCHAR(100)  DEFAULT NULL,
    model           VARCHAR(100)  DEFAULT NULL,
    firmware_ver    VARCHAR(50)   DEFAULT NULL,
    consumer_id     INT UNSIGNED  NOT NULL,
    location_id     INT UNSIGNED  NOT NULL,
    tariff_id       INT UNSIGNED  NOT NULL,
    installation_date DATE        NOT NULL,
    last_calibration  DATE        DEFAULT NULL,
    status          ENUM('ACTIVE','INACTIVE','FAULTY','DECOMMISSIONED')
                        NOT NULL DEFAULT 'ACTIVE',
    communication   ENUM('RF','GPRS','NB_IOT','WIFI','LORA')
                        NOT NULL DEFAULT 'GPRS',
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_meter_consumer
        FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_meter_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_meter_tariff
        FOREIGN KEY (tariff_id) REFERENCES tariff_plans(tariff_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_meter_status (status),
    INDEX idx_meter_consumer (consumer_id)
) ENGINE=InnoDB;


-- ============================================================
-- 6. METER READINGS (Time-Series Data)
-- ============================================================

CREATE TABLE IF NOT EXISTS meter_readings (
    reading_id      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    meter_id        INT UNSIGNED   NOT NULL,
    reading_time    DATETIME       NOT NULL,
    energy_kwh      DECIMAL(12,4)  NOT NULL,           -- cumulative kWh reading
    power_kw        DECIMAL(10,4)  DEFAULT NULL,       -- instantaneous power
    voltage_v       DECIMAL(7,2)   DEFAULT NULL,
    current_a       DECIMAL(7,2)   DEFAULT NULL,
    frequency_hz    DECIMAL(5,2)   DEFAULT NULL,
    power_factor    DECIMAL(4,3)   DEFAULT NULL,
    reading_source  ENUM('AUTO','MANUAL','ESTIMATED')
                        NOT NULL DEFAULT 'AUTO',
    created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reading_meter
        FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    UNIQUE KEY uk_meter_reading_time (meter_id, reading_time),
    INDEX idx_reading_time (reading_time),
    INDEX idx_reading_meter_time (meter_id, reading_time)
) ENGINE=InnoDB;


-- ============================================================
-- 7. DAILY CONSUMPTION AGGREGATES
-- ============================================================

CREATE TABLE IF NOT EXISTS daily_consumption (
    consumption_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    meter_id        INT UNSIGNED   NOT NULL,
    consumption_date DATE          NOT NULL,
    total_kwh       DECIMAL(12,4)  NOT NULL,
    peak_kwh        DECIMAL(12,4)  DEFAULT NULL,       -- peak hours consumption
    off_peak_kwh    DECIMAL(12,4)  DEFAULT NULL,       -- off-peak hours consumption
    max_demand_kw   DECIMAL(10,4)  DEFAULT NULL,       -- maximum demand recorded
    avg_voltage     DECIMAL(7,2)   DEFAULT NULL,
    avg_power_factor DECIMAL(4,3)  DEFAULT NULL,
    created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_daily_meter
        FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    UNIQUE KEY uk_daily_meter_date (meter_id, consumption_date),
    INDEX idx_daily_date (consumption_date)
) ENGINE=InnoDB;


-- ============================================================
-- 8. BILLING
-- ============================================================

CREATE TABLE IF NOT EXISTS bills (
    bill_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bill_number     VARCHAR(30)   NOT NULL UNIQUE,
    consumer_id     INT UNSIGNED  NOT NULL,
    meter_id        INT UNSIGNED  NOT NULL,
    billing_period_start DATE     NOT NULL,
    billing_period_end   DATE     NOT NULL,
    previous_reading DECIMAL(12,4) NOT NULL,
    current_reading  DECIMAL(12,4) NOT NULL,
    units_consumed  DECIMAL(12,4)  NOT NULL,
    energy_charge   DECIMAL(12,2)  NOT NULL,
    fixed_charge    DECIMAL(10,2)  NOT NULL DEFAULT 0,
    demand_charge   DECIMAL(10,2)  NOT NULL DEFAULT 0,
    tax_amount      DECIMAL(10,2)  NOT NULL DEFAULT 0,
    surcharge       DECIMAL(10,2)  NOT NULL DEFAULT 0,
    subsidy         DECIMAL(10,2)  NOT NULL DEFAULT 0,
    total_amount    DECIMAL(12,2)  NOT NULL,
    due_date        DATE           NOT NULL,
    bill_status     ENUM('GENERATED','SENT','PAID','OVERDUE','DISPUTED','CANCELLED')
                        NOT NULL DEFAULT 'GENERATED',
    generated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_bill_consumer
        FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_bill_meter
        FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_bill_consumer (consumer_id),
    INDEX idx_bill_status (bill_status),
    INDEX idx_bill_due (due_date),
    INDEX idx_bill_period (billing_period_start, billing_period_end)
) ENGINE=InnoDB;


-- ============================================================
-- 9. PAYMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS payments (
    payment_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_ref     VARCHAR(50)   NOT NULL UNIQUE,
    bill_id         INT UNSIGNED  NOT NULL,
    consumer_id     INT UNSIGNED  NOT NULL,
    amount_paid     DECIMAL(12,2) NOT NULL,
    payment_method  ENUM('CASH','UPI','NETBANKING','CREDIT_CARD','DEBIT_CARD','WALLET','CHEQUE','AUTO_DEBIT')
                        NOT NULL,
    payment_date    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transaction_id  VARCHAR(100)  DEFAULT NULL,
    payment_status  ENUM('SUCCESS','FAILED','PENDING','REFUNDED')
                        NOT NULL DEFAULT 'SUCCESS',
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_bill
        FOREIGN KEY (bill_id) REFERENCES bills(bill_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_payment_consumer
        FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_payment_consumer (consumer_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB;


-- ============================================================
-- 10. PREPAID WALLET (for prepaid meters)
-- ============================================================

CREATE TABLE IF NOT EXISTS prepaid_wallets (
    wallet_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    consumer_id     INT UNSIGNED  NOT NULL UNIQUE,
    balance         DECIMAL(12,2) NOT NULL DEFAULT 0,
    low_balance_threshold DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    auto_recharge   BOOLEAN       NOT NULL DEFAULT FALSE,
    last_recharged  DATETIME      DEFAULT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_wallet_consumer
        FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS wallet_transactions (
    txn_id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    wallet_id       INT UNSIGNED  NOT NULL,
    txn_type        ENUM('RECHARGE','DEDUCTION','REFUND','ADJUSTMENT')
                        NOT NULL,
    amount          DECIMAL(12,2) NOT NULL,
    balance_after   DECIMAL(12,2) NOT NULL,
    description     VARCHAR(255)  DEFAULT NULL,
    txn_time        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_wallet_txn
        FOREIGN KEY (wallet_id) REFERENCES prepaid_wallets(wallet_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    INDEX idx_wallet_txn_time (wallet_id, txn_time)
) ENGINE=InnoDB;


-- ============================================================
-- 11. ALERTS & NOTIFICATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS alerts (
    alert_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    meter_id        INT UNSIGNED  NOT NULL,
    consumer_id     INT UNSIGNED  NOT NULL,
    alert_type      ENUM('HIGH_USAGE','LOW_VOLTAGE','POWER_OUTAGE','TAMPER_DETECT',
                         'METER_FAULT','LOW_BALANCE','OVERLOAD','PAYMENT_DUE',
                         'SCHEDULED_MAINTENANCE','ABNORMAL_PATTERN')
                        NOT NULL,
    severity        ENUM('INFO','WARNING','CRITICAL')
                        NOT NULL DEFAULT 'INFO',
    message         TEXT          NOT NULL,
    is_read         BOOLEAN       NOT NULL DEFAULT FALSE,
    is_resolved     BOOLEAN       NOT NULL DEFAULT FALSE,
    resolved_at     DATETIME      DEFAULT NULL,
    triggered_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alert_meter
        FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_alert_consumer
        FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    INDEX idx_alert_type (alert_type),
    INDEX idx_alert_severity (severity),
    INDEX idx_alert_consumer (consumer_id, is_read),
    INDEX idx_alert_meter_time (meter_id, triggered_at)
) ENGINE=InnoDB;


-- ============================================================
-- 12. METER EVENTS / AUDIT LOG
-- ============================================================

CREATE TABLE IF NOT EXISTS meter_events (
    event_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    meter_id        INT UNSIGNED  NOT NULL,
    event_type      ENUM('POWER_ON','POWER_OFF','TAMPER_OPEN','TAMPER_CLOSE',
                         'FIRMWARE_UPDATE','CALIBRATION','RECONNECT','DISCONNECT',
                         'COMMUNICATION_LOSS','COMMUNICATION_RESTORE','OVERLOAD','RESET')
                        NOT NULL,
    event_time      DATETIME      NOT NULL,
    details         JSON          DEFAULT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_event_meter
        FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    INDEX idx_event_meter_time (meter_id, event_time),
    INDEX idx_event_type (event_type)
) ENGINE=InnoDB;


-- ============================================================
-- 13. MAINTENANCE & SERVICE REQUESTS
-- ============================================================

CREATE TABLE IF NOT EXISTS service_requests (
    request_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_number  VARCHAR(30)   NOT NULL UNIQUE,
    consumer_id     INT UNSIGNED  NOT NULL,
    meter_id        INT UNSIGNED  DEFAULT NULL,
    request_type    ENUM('NEW_CONNECTION','METER_REPLACEMENT','METER_TESTING',
                         'BILLING_DISPUTE','DISCONNECTION','RECONNECTION',
                         'TARIFF_CHANGE','NAME_TRANSFER','GENERAL_INQUIRY')
                        NOT NULL,
    priority        ENUM('LOW','MEDIUM','HIGH','URGENT')
                        NOT NULL DEFAULT 'MEDIUM',
    description     TEXT          NOT NULL,
    status          ENUM('OPEN','IN_PROGRESS','RESOLVED','CLOSED','REJECTED')
                        NOT NULL DEFAULT 'OPEN',
    assigned_to     VARCHAR(150)  DEFAULT NULL,
    resolution_notes TEXT         DEFAULT NULL,
    opened_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at     DATETIME      DEFAULT NULL,
    closed_at       DATETIME      DEFAULT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_sr_consumer
        FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_sr_meter
        FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    INDEX idx_sr_status (status),
    INDEX idx_sr_consumer (consumer_id),
    INDEX idx_sr_type (request_type)
) ENGINE=InnoDB;


-- ============================================================
-- 14. OUTAGE TRACKING
-- ============================================================

CREATE TABLE IF NOT EXISTS outages (
    outage_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    region_id       INT UNSIGNED  NOT NULL,
    outage_type     ENUM('PLANNED','UNPLANNED','EMERGENCY','LOAD_SHEDDING')
                        NOT NULL,
    cause           VARCHAR(255)  DEFAULT NULL,
    affected_meters INT UNSIGNED  DEFAULT 0,
    started_at      DATETIME      NOT NULL,
    estimated_restore DATETIME    DEFAULT NULL,
    restored_at     DATETIME      DEFAULT NULL,
    status          ENUM('ONGOING','RESTORED','CANCELLED')
                        NOT NULL DEFAULT 'ONGOING',
    notes           TEXT          DEFAULT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_outage_region
        FOREIGN KEY (region_id) REFERENCES regions(region_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_outage_status (status),
    INDEX idx_outage_region (region_id, started_at)
) ENGINE=InnoDB;


-- ============================================================
-- 15. AUDIT LOG (System-Level)
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_log (
    log_id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_name      VARCHAR(100)  NOT NULL,
    record_id       VARCHAR(50)   NOT NULL,
    action          ENUM('INSERT','UPDATE','DELETE')
                        NOT NULL,
    old_values      JSON          DEFAULT NULL,
    new_values      JSON          DEFAULT NULL,
    performed_by    VARCHAR(150)  DEFAULT NULL,
    performed_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_audit_table (table_name, record_id),
    INDEX idx_audit_time (performed_at)
) ENGINE=InnoDB;


-- ============================================================
-- 16. VIEWS
-- ============================================================

-- Consumer billing summary view
CREATE OR REPLACE VIEW vw_consumer_billing_summary AS
SELECT
    c.consumer_id,
    c.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    c.consumer_type,
    c.email,
    c.phone,
    es.supplier_name,
    m.meter_serial,
    m.meter_type,
    COUNT(b.bill_id)                        AS total_bills,
    COALESCE(SUM(b.total_amount), 0)        AS total_billed,
    COALESCE(SUM(p.amount_paid), 0)         AS total_paid,
    COALESCE(SUM(b.total_amount), 0)
        - COALESCE(SUM(p.amount_paid), 0)   AS outstanding_balance
FROM consumers c
JOIN energy_suppliers es ON c.supplier_id = es.supplier_id
LEFT JOIN meters m       ON m.consumer_id = c.consumer_id AND m.status = 'ACTIVE'
LEFT JOIN bills b        ON b.consumer_id = c.consumer_id
LEFT JOIN payments p     ON p.bill_id = b.bill_id AND p.payment_status = 'SUCCESS'
GROUP BY c.consumer_id, c.account_number, consumer_name, c.consumer_type,
         c.email, c.phone, es.supplier_name, m.meter_serial, m.meter_type;


-- Monthly consumption trend view
CREATE OR REPLACE VIEW vw_monthly_consumption AS
SELECT
    m.meter_id,
    m.meter_serial,
    c.consumer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    YEAR(dc.consumption_date)               AS consumption_year,
    MONTH(dc.consumption_date)              AS consumption_month,
    SUM(dc.total_kwh)                       AS monthly_kwh,
    AVG(dc.avg_voltage)                     AS avg_voltage,
    MAX(dc.max_demand_kw)                   AS peak_demand_kw
FROM daily_consumption dc
JOIN meters m    ON dc.meter_id = m.meter_id
JOIN consumers c ON m.consumer_id = c.consumer_id
GROUP BY m.meter_id, m.meter_serial, c.consumer_id, consumer_name,
         consumption_year, consumption_month;


-- Active alerts dashboard view
CREATE OR REPLACE VIEW vw_active_alerts AS
SELECT
    a.alert_id,
    a.alert_type,
    a.severity,
    a.message,
    a.triggered_at,
    m.meter_serial,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    c.phone,
    l.city,
    r.region_name
FROM alerts a
JOIN meters m     ON a.meter_id = m.meter_id
JOIN consumers c  ON a.consumer_id = c.consumer_id
JOIN locations l  ON m.location_id = l.location_id
JOIN regions r    ON l.region_id = r.region_id
WHERE a.is_resolved = FALSE
ORDER BY
    FIELD(a.severity, 'CRITICAL', 'WARNING', 'INFO'),
    a.triggered_at DESC;


-- Revenue by region view
CREATE OR REPLACE VIEW vw_revenue_by_region AS
SELECT
    r.region_id,
    r.region_name,
    r.state,
    COUNT(DISTINCT c.consumer_id)           AS total_consumers,
    COUNT(DISTINCT m.meter_id)              AS total_meters,
    COALESCE(SUM(b.total_amount), 0)        AS total_revenue,
    COALESCE(SUM(p.amount_paid), 0)         AS total_collected,
    COALESCE(SUM(b.total_amount), 0)
        - COALESCE(SUM(p.amount_paid), 0)   AS outstanding
FROM regions r
LEFT JOIN locations l    ON l.region_id = r.region_id
LEFT JOIN consumers c    ON c.location_id = l.location_id
LEFT JOIN meters m       ON m.consumer_id = c.consumer_id
LEFT JOIN bills b        ON b.consumer_id = c.consumer_id
LEFT JOIN payments p     ON p.bill_id = b.bill_id AND p.payment_status = 'SUCCESS'
GROUP BY r.region_id, r.region_name, r.state;


-- ============================================================
-- 17. STORED PROCEDURES
-- ============================================================

DELIMITER //

-- Procedure: Calculate bill for a meter over a billing period
CREATE PROCEDURE sp_generate_bill(
    IN p_meter_id       INT UNSIGNED,
    IN p_period_start   DATE,
    IN p_period_end     DATE
)
BEGIN
    DECLARE v_consumer_id   INT UNSIGNED;
    DECLARE v_tariff_id     INT UNSIGNED;
    DECLARE v_prev_reading  DECIMAL(12,4);
    DECLARE v_curr_reading  DECIMAL(12,4);
    DECLARE v_units         DECIMAL(12,4);
    DECLARE v_energy_charge DECIMAL(12,2) DEFAULT 0;
    DECLARE v_fixed_charge  DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tax           DECIMAL(10,2);
    DECLARE v_total         DECIMAL(12,2);
    DECLARE v_bill_number   VARCHAR(30);

    -- Get meter details
    SELECT consumer_id, tariff_id
    INTO v_consumer_id, v_tariff_id
    FROM meters WHERE meter_id = p_meter_id AND status = 'ACTIVE';

    -- Get previous reading (closest to period start)
    SELECT energy_kwh INTO v_prev_reading
    FROM meter_readings
    WHERE meter_id = p_meter_id AND reading_time <= p_period_start
    ORDER BY reading_time DESC LIMIT 1;

    -- Get current reading (closest to period end)
    SELECT energy_kwh INTO v_curr_reading
    FROM meter_readings
    WHERE meter_id = p_meter_id AND reading_time <= CONCAT(p_period_end, ' 23:59:59')
    ORDER BY reading_time DESC LIMIT 1;

    SET v_units = v_curr_reading - v_prev_reading;

    -- Calculate energy charge from tariff slabs
    SELECT COALESCE(SUM(
        CASE
            WHEN v_units > min_units THEN
                (LEAST(v_units, COALESCE(max_units, v_units)) - min_units) * rate_per_unit
            ELSE 0
        END
    ), 0),
    COALESCE(SUM(fixed_charge), 0)
    INTO v_energy_charge, v_fixed_charge
    FROM tariff_slabs
    WHERE tariff_id = v_tariff_id;

    -- Tax at 5%
    SET v_tax = ROUND((v_energy_charge + v_fixed_charge) * 0.05, 2);
    SET v_total = v_energy_charge + v_fixed_charge + v_tax;

    -- Generate bill number
    SET v_bill_number = CONCAT('BILL-', p_meter_id, '-',
                               DATE_FORMAT(p_period_end, '%Y%m'));

    -- Insert the bill
    INSERT INTO bills (
        bill_number, consumer_id, meter_id,
        billing_period_start, billing_period_end,
        previous_reading, current_reading, units_consumed,
        energy_charge, fixed_charge, tax_amount, total_amount,
        due_date, bill_status
    ) VALUES (
        v_bill_number, v_consumer_id, p_meter_id,
        p_period_start, p_period_end,
        v_prev_reading, v_curr_reading, v_units,
        v_energy_charge, v_fixed_charge, v_tax, v_total,
        DATE_ADD(p_period_end, INTERVAL 15 DAY), 'GENERATED'
    );

    SELECT v_bill_number AS generated_bill, v_units AS units,
           v_energy_charge AS energy_charge, v_total AS total_amount;
END //


-- Procedure: Get consumption analytics for a consumer
CREATE PROCEDURE sp_consumption_analytics(
    IN p_consumer_id    INT UNSIGNED,
    IN p_months         INT
)
BEGIN
    SELECT
        DATE_FORMAT(dc.consumption_date, '%Y-%m') AS month,
        SUM(dc.total_kwh)                         AS total_kwh,
        AVG(dc.total_kwh)                         AS avg_daily_kwh,
        MAX(dc.max_demand_kw)                     AS peak_demand_kw,
        AVG(dc.avg_voltage)                       AS avg_voltage,
        AVG(dc.avg_power_factor)                  AS avg_power_factor
    FROM daily_consumption dc
    JOIN meters m ON dc.meter_id = m.meter_id
    WHERE m.consumer_id = p_consumer_id
      AND dc.consumption_date >= DATE_SUB(CURDATE(), INTERVAL p_months MONTH)
    GROUP BY month
    ORDER BY month DESC;
END //


-- Procedure: Record a payment and update bill status
CREATE PROCEDURE sp_record_payment(
    IN p_bill_id        INT UNSIGNED,
    IN p_amount         DECIMAL(12,2),
    IN p_method         VARCHAR(20),
    IN p_transaction_id VARCHAR(100)
)
BEGIN
    DECLARE v_consumer_id INT UNSIGNED;
    DECLARE v_total       DECIMAL(12,2);
    DECLARE v_paid        DECIMAL(12,2);
    DECLARE v_ref         VARCHAR(50);

    SELECT consumer_id, total_amount INTO v_consumer_id, v_total
    FROM bills WHERE bill_id = p_bill_id;

    -- Generate payment reference
    SET v_ref = CONCAT('PAY-', p_bill_id, '-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'));

    INSERT INTO payments (payment_ref, bill_id, consumer_id, amount_paid,
                         payment_method, transaction_id, payment_status)
    VALUES (v_ref, p_bill_id, v_consumer_id, p_amount,
            p_method, p_transaction_id, 'SUCCESS');

    -- Check total paid for this bill
    SELECT COALESCE(SUM(amount_paid), 0) INTO v_paid
    FROM payments
    WHERE bill_id = p_bill_id AND payment_status = 'SUCCESS';

    -- Update bill status
    IF v_paid >= v_total THEN
        UPDATE bills SET bill_status = 'PAID' WHERE bill_id = p_bill_id;
    END IF;

    SELECT v_ref AS payment_reference, v_paid AS total_paid,
           v_total AS bill_total,
           CASE WHEN v_paid >= v_total THEN 'PAID' ELSE 'PARTIAL' END AS status;
END //

DELIMITER ;


-- ============================================================
-- 18. TRIGGERS
-- ============================================================

DELIMITER //

-- Trigger: Auto-create alerts for overdue bills
CREATE TRIGGER trg_bill_overdue_alert
AFTER UPDATE ON bills
FOR EACH ROW
BEGIN
    IF NEW.bill_status = 'OVERDUE' AND OLD.bill_status != 'OVERDUE' THEN
        INSERT INTO alerts (meter_id, consumer_id, alert_type, severity, message)
        SELECT NEW.meter_id, NEW.consumer_id, 'PAYMENT_DUE', 'WARNING',
               CONCAT('Bill ', NEW.bill_number, ' of ₹', NEW.total_amount,
                       ' is overdue. Due date was ', NEW.due_date);
    END IF;
END //


-- Trigger: Low balance alert for prepaid meters
CREATE TRIGGER trg_wallet_low_balance
AFTER UPDATE ON prepaid_wallets
FOR EACH ROW
BEGIN
    DECLARE v_meter_id INT UNSIGNED;

    IF NEW.balance < NEW.low_balance_threshold
       AND OLD.balance >= OLD.low_balance_threshold THEN

        SELECT meter_id INTO v_meter_id
        FROM meters
        WHERE consumer_id = NEW.consumer_id AND status = 'ACTIVE'
        LIMIT 1;

        IF v_meter_id IS NOT NULL THEN
            INSERT INTO alerts (meter_id, consumer_id, alert_type, severity, message)
            VALUES (v_meter_id, NEW.consumer_id, 'LOW_BALANCE', 'WARNING',
                    CONCAT('Prepaid balance is low: ₹', NEW.balance,
                           '. Threshold: ₹', NEW.low_balance_threshold));
        END IF;
    END IF;
END //


-- Trigger: Log meter status changes
CREATE TRIGGER trg_meter_status_audit
AFTER UPDATE ON meters
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, performed_by)
        VALUES ('meters', NEW.meter_id, 'UPDATE',
                JSON_OBJECT('status', OLD.status),
                JSON_OBJECT('status', NEW.status),
                CURRENT_USER());
    END IF;
END //

DELIMITER ;


-- ============================================================
-- End of Schema
-- ============================================================
