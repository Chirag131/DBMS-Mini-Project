USE smart_energy_db;

DELIMITER //

CREATE PROCEDURE add_new_customer(
    IN p_fname VARCHAR(50),
    IN p_lname VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address TEXT,
    IN p_city VARCHAR(40),
    IN p_pincode VARCHAR(10),
    IN p_meter_number VARCHAR(30),
    IN p_connection_type VARCHAR(20),
    IN p_meter_type VARCHAR(30)
)
BEGIN
    DECLARE new_cust_id INT;
    
    INSERT INTO customers (first_name, last_name, email, phone_no, address, city, pincode, meter_number, connection_type, connection_date)
    VALUES (p_fname, p_lname, p_email, p_phone, p_address, p_city, p_pincode, p_meter_number, p_connection_type, CURDATE());
    
    SET new_cust_id = LAST_INSERT_ID();
    
    INSERT INTO meters (meter_number, meter_type, install_date, status, cust_id, location)
    VALUES (p_meter_number, p_meter_type, CURDATE(), 'working', new_cust_id, CONCAT(p_address, ', ', p_city));
    
    SELECT 'Customer added successfully!' AS message, new_cust_id AS customer_id;
END //

CREATE PROCEDURE generate_bill(
    IN p_cust_id INT,
    IN p_meter_id INT,
    IN p_units DECIMAL(10,2),
    IN p_billing_month VARCHAR(20)
)
BEGIN
    DECLARE v_rate DECIMAL(6,2);
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_tax DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_conn_type VARCHAR(20);
    
    SELECT connection_type INTO v_conn_type FROM customers WHERE cust_id = p_cust_id;
    
    SELECT rate_per_unit INTO v_rate 
    FROM tariff_plan 
    WHERE connection_type = v_conn_type 
    AND p_units BETWEEN min_units AND max_units
    AND CURDATE() BETWEEN effective_from AND effective_to
    LIMIT 1;
    
    SET v_amount = p_units * v_rate;
    SET v_tax = v_amount * 0.10;
    SET v_total = v_amount + v_tax;
    
    INSERT INTO bills (cust_id, meter_id, billing_month, bill_date, units_consumed, amount, tax, total_amount, due_date, status)
    VALUES (p_cust_id, p_meter_id, p_billing_month, CURDATE(), p_units, v_amount, v_tax, v_total, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'unpaid');
    
    SELECT 'Bill generated!' AS message, v_total AS total_bill_amount;
END //

CREATE PROCEDURE process_payment(
    IN p_bill_id INT,
    IN p_amount DECIMAL(10,2),
    IN p_mode VARCHAR(30),
    IN p_txn_id VARCHAR(50)
)
BEGIN
    DECLARE v_cust_id INT;
    DECLARE v_bill_total DECIMAL(10,2);
    
    SELECT cust_id, total_amount INTO v_cust_id, v_bill_total 
    FROM bills WHERE bill_id = p_bill_id;
    
    IF p_amount >= v_bill_total THEN
        INSERT INTO payments (bill_id, cust_id, payment_date, amount_paid, payment_mode, transaction_id, payment_status)
        VALUES (p_bill_id, v_cust_id, NOW(), p_amount, p_mode, p_txn_id, 'success');
        
        UPDATE bills SET status = 'paid' WHERE bill_id = p_bill_id;
        
        INSERT INTO notifications (cust_id, notif_type, message, sent_via)
        VALUES (v_cust_id, 'payment_received', 
                CONCAT('Your payment of Rs.', p_amount, ' has been received for bill #', p_bill_id, '. Thank you!'),
                'sms');
        
        SELECT 'Payment successful!' AS message;
    ELSE
        SELECT 'Error: Amount paid is less than bill amount!' AS message;
    END IF;
END //

CREATE PROCEDURE get_customer_details(
    IN p_cust_id INT
)
BEGIN
    SELECT * FROM customers WHERE cust_id = p_cust_id;
    
    SELECT * FROM meters WHERE cust_id = p_cust_id;
    
    SELECT * FROM bills WHERE cust_id = p_cust_id ORDER BY bill_date DESC LIMIT 5;
    
    SELECT * FROM payments WHERE cust_id = p_cust_id ORDER BY payment_date DESC LIMIT 5;
    
    SELECT * FROM complaints WHERE cust_id = p_cust_id AND status IN ('open', 'in_progress');
END //

CREATE PROCEDURE mark_overdue_bills()
BEGIN
    DECLARE overdue_count INT;
    
    UPDATE bills 
    SET status = 'overdue' 
    WHERE status = 'unpaid' AND due_date < CURDATE();
    
    SET overdue_count = ROW_COUNT();
    
    SELECT CONCAT(overdue_count, ' bills marked as overdue') AS message;
END //

CREATE PROCEDURE register_complaint(
    IN p_cust_id INT,
    IN p_meter_id INT,
    IN p_type VARCHAR(50),
    IN p_description TEXT,
    IN p_priority VARCHAR(10)
)
BEGIN
    INSERT INTO complaints (cust_id, meter_id, complaint_type, description, priority)
    VALUES (p_cust_id, p_meter_id, p_type, p_description, p_priority);
    
    SELECT 'Complaint registered successfully!' AS message, LAST_INSERT_ID() AS complaint_id;
END //

DELIMITER ;
