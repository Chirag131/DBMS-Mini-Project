USE smart_energy_db;

DELIMITER //

CREATE TRIGGER after_bill_generated
AFTER INSERT ON bills
FOR EACH ROW
BEGIN
    DECLARE v_name VARCHAR(100);
    
    SELECT CONCAT(first_name, ' ', last_name) INTO v_name 
    FROM customers WHERE cust_id = NEW.cust_id;
    
    INSERT INTO notifications (cust_id, notif_type, message, sent_via)
    VALUES (NEW.cust_id, 'bill_generated',
            CONCAT('Dear ', v_name, ', your electricity bill for ', NEW.billing_month, 
                   ' is Rs.', NEW.total_amount, '. Due date: ', NEW.due_date, '.'),
            'sms');
END //

CREATE TRIGGER after_payment_made
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'success' THEN
        UPDATE bills SET status = 'paid' WHERE bill_id = NEW.bill_id;
    END IF;
END //

CREATE TRIGGER before_customer_delete
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
    DECLARE unpaid_count INT;
    
    SELECT COUNT(*) INTO unpaid_count 
    FROM bills 
    WHERE cust_id = OLD.cust_id AND status IN ('unpaid', 'overdue');
    
    IF unpaid_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete customer with unpaid bills!';
    END IF;
END //

CREATE TRIGGER after_complaint_resolved
BEFORE UPDATE ON complaints
FOR EACH ROW
BEGIN
    IF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
        SET NEW.resolved_date = NOW();
    END IF;
END //

CREATE TRIGGER after_meter_status_change
AFTER UPDATE ON meters
FOR EACH ROW
BEGIN
    IF NEW.status = 'faulty' AND OLD.status = 'working' THEN
        INSERT INTO complaints (cust_id, meter_id, complaint_type, description, priority, assigned_to)
        VALUES (NEW.cust_id, NEW.meter_id, 'meter fault', 
                CONCAT('Meter ', NEW.meter_number, ' has been marked as faulty. Auto-generated complaint.'),
                'high', 'Harpreet Singh');
    END IF;
END //

DELIMITER ;
