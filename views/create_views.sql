USE smart_energy_db;

CREATE OR REPLACE VIEW customer_bill_summary AS
SELECT 
    c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone_no,
    c.city,
    c.connection_type,
    b.billing_month,
    b.units_consumed,
    b.total_amount,
    b.status AS bill_status
FROM customers c
JOIN bills b ON c.cust_id = b.cust_id
ORDER BY c.cust_id;

CREATE OR REPLACE VIEW overdue_bills_view AS
SELECT 
    c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone_no,
    c.email,
    b.bill_id,
    b.billing_month,
    b.total_amount,
    b.due_date,
    DATEDIFF(CURDATE(), b.due_date) AS days_overdue
FROM customers c
JOIN bills b ON c.cust_id = b.cust_id
WHERE b.status = 'overdue'
ORDER BY days_overdue DESC;

CREATE OR REPLACE VIEW meter_health_view AS
SELECT 
    m.meter_id,
    m.meter_number,
    m.meter_type,
    m.manufacturer,
    m.status AS meter_status,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone_no,
    m.location,
    DATEDIFF(CURDATE(), m.install_date) AS days_since_installation
FROM meters m
JOIN customers c ON m.cust_id = c.cust_id
WHERE m.status != 'working';

CREATE OR REPLACE VIEW monthly_consumption_report AS
SELECT 
    c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.connection_type,
    c.city,
    er.reading_date,
    er.units_consumed,
    er.previous_reading,
    er.current_reading,
    er.recorded_by
FROM customers c
JOIN energy_readings er ON c.cust_id = er.cust_id
ORDER BY er.reading_date DESC;

CREATE OR REPLACE VIEW payment_history_view AS
SELECT 
    p.payment_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    b.billing_month,
    b.total_amount AS bill_amount,
    p.amount_paid,
    p.payment_date,
    p.payment_mode,
    p.transaction_id,
    p.payment_status
FROM payments p
JOIN customers c ON p.cust_id = c.cust_id
JOIN bills b ON p.bill_id = b.bill_id
ORDER BY p.payment_date DESC;

CREATE OR REPLACE VIEW active_complaints_view AS
SELECT 
    comp.complaint_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone_no,
    m.meter_number,
    comp.complaint_type,
    comp.description,
    comp.status AS complaint_status,
    comp.priority,
    comp.assigned_to,
    comp.complaint_date,
    DATEDIFF(CURDATE(), comp.complaint_date) AS pending_days
FROM complaints comp
JOIN customers c ON comp.cust_id = c.cust_id
JOIN meters m ON comp.meter_id = m.meter_id
WHERE comp.status IN ('open', 'in_progress')
ORDER BY 
    CASE comp.priority 
        WHEN 'high' THEN 1 
        WHEN 'medium' THEN 2 
        WHEN 'low' THEN 3 
    END;
