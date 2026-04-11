USE smart_energy_db;

SELECT 
    c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS name,
    c.phone_no,
    c.city,
    m.meter_number,
    m.meter_type,
    m.status
FROM customers c
JOIN meters m ON c.cust_id = m.cust_id;

SELECT 
    b.bill_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    b.billing_month,
    b.total_amount,
    b.due_date,
    b.status
FROM bills b
JOIN customers c ON b.cust_id = c.cust_id
WHERE b.status IN ('unpaid', 'overdue')
ORDER BY b.due_date;

SELECT 
    SUM(amount_paid) AS total_revenue,
    COUNT(*) AS total_payments,
    payment_mode,
    COUNT(*) AS count_per_mode
FROM payments
WHERE MONTH(payment_date) = MONTH(CURDATE())
GROUP BY payment_mode;

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    c.connection_type,
    SUM(er.units_consumed) AS total_units
FROM energy_readings er
JOIN customers c ON er.cust_id = c.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name, c.connection_type
ORDER BY total_units DESC
LIMIT 5;

SELECT 
    cust_id,
    CONCAT(first_name, ' ', last_name) AS customer,
    phone_no,
    city
FROM customers
WHERE cust_id NOT IN (
    SELECT DISTINCT cust_id FROM complaints
);

SELECT 
    c.connection_type,
    COUNT(*) AS total_bills,
    ROUND(AVG(b.total_amount), 2) AS avg_bill,
    ROUND(MIN(b.total_amount), 2) AS min_bill,
    ROUND(MAX(b.total_amount), 2) AS max_bill
FROM bills b
JOIN customers c ON b.cust_id = c.cust_id
GROUP BY c.connection_type;

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    b.total_amount,
    b.billing_month
FROM bills b
JOIN customers c ON b.cust_id = c.cust_id
WHERE b.total_amount > (
    SELECT AVG(total_amount) FROM bills
)
ORDER BY b.total_amount DESC;

SELECT 
    er.reading_date,
    er.units_consumed,
    er.previous_reading,
    er.current_reading
FROM energy_readings er
WHERE er.cust_id = 1
ORDER BY er.reading_date;

SELECT 
    assigned_to,
    COUNT(*) AS total_complaints,
    SUM(CASE WHEN status = 'resolved' THEN 1 ELSE 0 END) AS resolved,
    SUM(CASE WHEN status IN ('open', 'in_progress') THEN 1 ELSE 0 END) AS pending
FROM complaints
GROUP BY assigned_to;

SELECT 
    a.zone,
    a.area_name,
    a.total_connections,
    COALESCE(SUM(er.units_consumed), 0) AS total_consumption
FROM areas a
LEFT JOIN customers c ON c.city = a.city
LEFT JOIN energy_readings er ON c.cust_id = er.cust_id
GROUP BY a.area_id, a.zone, a.area_name, a.total_connections
ORDER BY total_consumption DESC;

SELECT phone_no, COUNT(*) AS cnt
FROM customers
GROUP BY phone_no
HAVING COUNT(*) > 1;

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    m.meter_number,
    m.status AS meter_status,
    b.total_amount,
    b.status AS bill_status
FROM customers c
JOIN meters m ON c.cust_id = m.cust_id
JOIN bills b ON c.cust_id = b.cust_id
WHERE m.status = 'faulty' AND b.status IN ('unpaid', 'overdue');

SELECT * FROM overdue_bills_view;

SELECT * FROM meter_health_view;

SELECT * FROM active_complaints_view;

CALL add_new_customer('Deepak', 'Mehta', 'deepak@gmail.com', '9900000001', '101, Sector 44', 'Chandigarh', '160044', 'MTR011', 'domestic', 'smart');

CALL generate_bill(1, 1, 300.00, 'April 2026');

CALL process_payment(3, 17333.67, 'netbanking', 'TXN20260411001');

CALL mark_overdue_bills();

CALL get_customer_details(1);

CALL register_complaint(2, 2, 'wrong bill', 'Bill seems incorrect, usage was very low this month', 'low');
