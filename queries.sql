-- ============================================================
-- Smart Energy Metering - Sample Queries
-- A collection of useful analytical and operational queries
-- ============================================================

USE smart_energy_metering;

-- ============================================================
-- SECTION 1: CONSUMER QUERIES
-- ============================================================

-- Q1: Get all active consumers with their meter and location details
SELECT
    c.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    c.consumer_type,
    c.email,
    c.phone,
    m.meter_serial,
    m.meter_type,
    m.status AS meter_status,
    l.address_line1,
    l.city,
    l.pincode,
    es.supplier_name
FROM consumers c
JOIN meters m           ON m.consumer_id = c.consumer_id
JOIN locations l        ON c.location_id = l.location_id
JOIN energy_suppliers es ON c.supplier_id = es.supplier_id
WHERE c.is_active = TRUE AND m.status = 'ACTIVE'
ORDER BY c.consumer_type, c.last_name;


-- Q2: Count consumers by type and region
SELECT
    r.region_name,
    r.state,
    c.consumer_type,
    COUNT(*) AS consumer_count
FROM consumers c
JOIN locations l ON c.location_id = l.location_id
JOIN regions r   ON l.region_id = r.region_id
GROUP BY r.region_name, r.state, c.consumer_type
ORDER BY r.state, r.region_name, c.consumer_type;


-- Q3: Find consumers with outstanding balance
SELECT
    c.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    b.bill_number,
    b.total_amount,
    COALESCE(SUM(p.amount_paid), 0) AS paid,
    b.total_amount - COALESCE(SUM(p.amount_paid), 0) AS outstanding,
    b.due_date,
    DATEDIFF(CURDATE(), b.due_date) AS days_overdue
FROM consumers c
JOIN bills b     ON b.consumer_id = c.consumer_id
LEFT JOIN payments p ON p.bill_id = b.bill_id AND p.payment_status = 'SUCCESS'
WHERE b.bill_status IN ('SENT', 'GENERATED', 'OVERDUE')
GROUP BY c.account_number, consumer_name, b.bill_number,
         b.total_amount, b.due_date
HAVING outstanding > 0
ORDER BY days_overdue DESC;


-- ============================================================
-- SECTION 2: CONSUMPTION ANALYTICS
-- ============================================================

-- Q4: Top 5 consumers by monthly energy consumption
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    c.consumer_type,
    m.meter_serial,
    SUM(dc.total_kwh) AS total_kwh_this_month,
    SUM(dc.peak_kwh)  AS peak_kwh,
    SUM(dc.off_peak_kwh) AS off_peak_kwh,
    MAX(dc.max_demand_kw) AS peak_demand_kw
FROM daily_consumption dc
JOIN meters m    ON dc.meter_id = m.meter_id
JOIN consumers c ON m.consumer_id = c.consumer_id
WHERE dc.consumption_date BETWEEN '2026-03-01' AND '2026-03-31'
GROUP BY c.consumer_id, consumer_name, c.consumer_type, m.meter_serial
ORDER BY total_kwh_this_month DESC
LIMIT 5;


-- Q5: Average daily consumption by consumer type
SELECT
    c.consumer_type,
    COUNT(DISTINCT c.consumer_id)   AS num_consumers,
    ROUND(AVG(dc.total_kwh), 2)     AS avg_daily_kwh,
    ROUND(MAX(dc.total_kwh), 2)     AS max_daily_kwh,
    ROUND(MIN(dc.total_kwh), 2)     AS min_daily_kwh
FROM daily_consumption dc
JOIN meters m    ON dc.meter_id = m.meter_id
JOIN consumers c ON m.consumer_id = c.consumer_id
GROUP BY c.consumer_type
ORDER BY avg_daily_kwh DESC;


-- Q6: Day-over-day consumption trend for a specific consumer
SELECT
    dc.consumption_date,
    dc.total_kwh,
    dc.peak_kwh,
    dc.off_peak_kwh,
    dc.max_demand_kw,
    dc.avg_voltage,
    dc.avg_power_factor,
    ROUND(dc.total_kwh - LAG(dc.total_kwh)
        OVER (ORDER BY dc.consumption_date), 2) AS change_from_prev_day
FROM daily_consumption dc
JOIN meters m ON dc.meter_id = m.meter_id
WHERE m.consumer_id = 1
ORDER BY dc.consumption_date;


-- Q7: Peak vs off-peak consumption ratio by consumer
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    c.consumer_type,
    SUM(dc.peak_kwh) AS total_peak,
    SUM(dc.off_peak_kwh) AS total_off_peak,
    ROUND(SUM(dc.peak_kwh) / NULLIF(SUM(dc.off_peak_kwh), 0), 2) AS peak_to_offpeak_ratio
FROM daily_consumption dc
JOIN meters m    ON dc.meter_id = m.meter_id
JOIN consumers c ON m.consumer_id = c.consumer_id
GROUP BY c.consumer_id, consumer_name, c.consumer_type
HAVING total_peak > 0 AND total_off_peak > 0
ORDER BY peak_to_offpeak_ratio DESC;


-- ============================================================
-- SECTION 3: BILLING & REVENUE
-- ============================================================

-- Q8: Monthly revenue summary
SELECT
    DATE_FORMAT(b.billing_period_end, '%Y-%m') AS billing_month,
    COUNT(b.bill_id) AS total_bills,
    SUM(b.units_consumed) AS total_units,
    SUM(b.energy_charge) AS total_energy_charge,
    SUM(b.tax_amount) AS total_tax,
    SUM(b.total_amount) AS total_revenue,
    SUM(CASE WHEN b.bill_status = 'PAID' THEN b.total_amount ELSE 0 END) AS collected,
    SUM(CASE WHEN b.bill_status IN ('SENT','GENERATED','OVERDUE')
        THEN b.total_amount ELSE 0 END) AS pending
FROM bills b
GROUP BY billing_month
ORDER BY billing_month DESC;


-- Q9: Revenue breakdown by consumer type
SELECT
    c.consumer_type,
    COUNT(DISTINCT c.consumer_id) AS consumers,
    COUNT(b.bill_id) AS bills,
    SUM(b.units_consumed) AS total_units,
    SUM(b.total_amount) AS total_revenue,
    ROUND(AVG(b.total_amount), 2) AS avg_bill_amount,
    ROUND(AVG(b.units_consumed), 2) AS avg_units_per_bill
FROM bills b
JOIN consumers c ON b.consumer_id = c.consumer_id
GROUP BY c.consumer_type
ORDER BY total_revenue DESC;


-- Q10: Payment method distribution
SELECT
    payment_method,
    COUNT(*) AS txn_count,
    SUM(amount_paid) AS total_amount,
    ROUND(AVG(amount_paid), 2) AS avg_amount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY payment_method
ORDER BY total_amount DESC;


-- ============================================================
-- SECTION 4: METER & INFRASTRUCTURE
-- ============================================================

-- Q11: Meter inventory by status and type
SELECT
    meter_type,
    status,
    communication,
    COUNT(*) AS meter_count,
    GROUP_CONCAT(meter_serial ORDER BY meter_serial) AS serial_numbers
FROM meters
GROUP BY meter_type, status, communication
ORDER BY meter_type, status;


-- Q12: Meters due for calibration (>12 months since last calibration)
SELECT
    m.meter_serial,
    m.meter_type,
    m.manufacturer,
    m.model,
    m.last_calibration,
    DATEDIFF(CURDATE(), m.last_calibration) AS days_since_calibration,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    l.city
FROM meters m
JOIN consumers c ON m.consumer_id = c.consumer_id
JOIN locations l ON m.location_id = l.location_id
WHERE m.status = 'ACTIVE'
  AND (m.last_calibration IS NULL
       OR m.last_calibration < DATE_SUB(CURDATE(), INTERVAL 12 MONTH))
ORDER BY m.last_calibration ASC;


-- Q13: Meters with communication issues (events in last 30 days)
SELECT
    m.meter_serial,
    m.communication,
    me.event_type,
    me.event_time,
    me.details,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    l.city
FROM meter_events me
JOIN meters m    ON me.meter_id = m.meter_id
JOIN consumers c ON m.consumer_id = c.consumer_id
JOIN locations l ON m.location_id = l.location_id
WHERE me.event_type IN ('COMMUNICATION_LOSS', 'COMMUNICATION_RESTORE')
  AND me.event_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY me.event_time DESC;


-- ============================================================
-- SECTION 5: ALERTS & EVENTS
-- ============================================================

-- Q14: Unresolved critical alerts
SELECT
    a.alert_id,
    a.alert_type,
    a.severity,
    a.message,
    a.triggered_at,
    DATEDIFF(NOW(), a.triggered_at) AS days_open,
    m.meter_serial,
    CONCAT(c.first_name, ' ', c.last_name) AS consumer_name,
    c.phone,
    l.city
FROM alerts a
JOIN meters m    ON a.meter_id = m.meter_id
JOIN consumers c ON a.consumer_id = c.consumer_id
JOIN locations l ON m.location_id = l.location_id
WHERE a.is_resolved = FALSE AND a.severity = 'CRITICAL'
ORDER BY a.triggered_at ASC;


-- Q15: Alert frequency by type (last 90 days)
SELECT
    alert_type,
    severity,
    COUNT(*) AS alert_count,
    SUM(CASE WHEN is_resolved = TRUE THEN 1 ELSE 0 END) AS resolved_count,
    SUM(CASE WHEN is_resolved = FALSE THEN 1 ELSE 0 END) AS open_count,
    ROUND(AVG(CASE
        WHEN is_resolved = TRUE
        THEN TIMESTAMPDIFF(HOUR, triggered_at, resolved_at)
        ELSE NULL
    END), 1) AS avg_resolution_hours
FROM alerts
WHERE triggered_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)
GROUP BY alert_type, severity
ORDER BY alert_count DESC;


-- ============================================================
-- SECTION 6: OUTAGE ANALYSIS
-- ============================================================

-- Q16: Outage history with duration
SELECT
    o.outage_id,
    r.region_name,
    r.state,
    o.outage_type,
    o.cause,
    o.affected_meters,
    o.started_at,
    o.restored_at,
    o.status,
    CASE
        WHEN o.restored_at IS NOT NULL
        THEN CONCAT(TIMESTAMPDIFF(HOUR, o.started_at, o.restored_at), 'h ',
                     TIMESTAMPDIFF(MINUTE, o.started_at, o.restored_at) % 60, 'm')
        ELSE 'Ongoing'
    END AS duration,
    o.notes
FROM outages o
JOIN regions r ON o.region_id = r.region_id
ORDER BY o.started_at DESC;


-- ============================================================
-- SECTION 7: OPERATIONAL DASHBOARD QUERIES
-- ============================================================

-- Q17: Overall system statistics
SELECT
    (SELECT COUNT(*) FROM consumers WHERE is_active = TRUE)    AS active_consumers,
    (SELECT COUNT(*) FROM meters WHERE status = 'ACTIVE')       AS active_meters,
    (SELECT COUNT(*) FROM meters WHERE status = 'FAULTY')       AS faulty_meters,
    (SELECT COUNT(*) FROM alerts WHERE is_resolved = FALSE)     AS open_alerts,
    (SELECT COUNT(*) FROM alerts WHERE is_resolved = FALSE
                                   AND severity = 'CRITICAL')   AS critical_alerts,
    (SELECT COUNT(*) FROM outages WHERE status = 'ONGOING')     AS ongoing_outages,
    (SELECT COUNT(*) FROM service_requests WHERE status IN ('OPEN', 'IN_PROGRESS'))
                                                                 AS open_service_requests;


-- Q18: Today's real-time meter health
SELECT
    m.status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM meters m
GROUP BY m.status;


-- Q19: Tariff slab breakdown for a specific plan
SELECT
    tp.plan_name,
    tp.plan_code,
    tp.consumer_type,
    ts.min_units,
    COALESCE(ts.max_units, 'Unlimited') AS max_units,
    ts.rate_per_unit AS rate_inr_per_kwh,
    ts.fixed_charge AS monthly_fixed_charge
FROM tariff_plans tp
JOIN tariff_slabs ts ON tp.tariff_id = ts.tariff_id
WHERE tp.is_active = TRUE
ORDER BY tp.consumer_type, tp.plan_name, ts.min_units;


-- Q20: Service request performance metrics
SELECT
    request_type,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN status = 'OPEN' THEN 1 ELSE 0 END) AS open_count,
    SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress,
    SUM(CASE WHEN status IN ('RESOLVED','CLOSED') THEN 1 ELSE 0 END) AS completed,
    ROUND(AVG(CASE
        WHEN resolved_at IS NOT NULL
        THEN TIMESTAMPDIFF(HOUR, opened_at, resolved_at)
        ELSE NULL
    END), 1) AS avg_resolution_hours
FROM service_requests
GROUP BY request_type
ORDER BY total_requests DESC;


-- ============================================================
-- End of Sample Queries
-- ============================================================
