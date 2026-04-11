-- ============================================================
-- Smart Energy Metering - Sample Seed Data
-- Run this AFTER schema.sql
-- ============================================================

USE smart_energy_metering;

-- ============================================================
-- 1. REGIONS
-- ============================================================

INSERT INTO regions (region_name, state) VALUES
('North Delhi',     'Delhi'),
('South Delhi',     'Delhi'),
('Gurugram',        'Haryana'),
('Noida',           'Uttar Pradesh'),
('Chandigarh',      'Chandigarh'),
('Jaipur',          'Rajasthan'),
('Lucknow',         'Uttar Pradesh'),
('Mumbai Central',  'Maharashtra'),
('Pune',            'Maharashtra'),
('Bengaluru Urban', 'Karnataka');


-- ============================================================
-- 2. LOCATIONS
-- ============================================================

INSERT INTO locations (region_id, address_line1, address_line2, city, pincode, latitude, longitude) VALUES
(1,  '42, Rajpur Road',         'Sector 5',        'New Delhi',    '110054', 28.7041000, 77.1025000),
(1,  '115, Model Town',         NULL,               'New Delhi',    '110009', 28.7130000, 77.1925000),
(2,  '78, Saket Main Road',     'Block J',          'New Delhi',    '110017', 28.5244000, 77.2066000),
(3,  'Tower B, DLF Phase 3',    'Golf Course Road', 'Gurugram',     '122002', 28.4595000, 77.0266000),
(4,  'A-45, Sector 62',         NULL,               'Noida',        '201301', 28.6270000, 77.3650000),
(5,  'SCO 34, Sector 17',       NULL,               'Chandigarh',   '160017', 30.7415000, 76.7682000),
(6,  '12, MI Road',             'Pink City',        'Jaipur',       '302001', 26.9124000, 75.7873000),
(7,  '56, Hazratganj',          NULL,               'Lucknow',      '226001', 26.8500000, 80.9500000),
(8,  'Flat 302, Andheri West',  'Off Link Road',    'Mumbai',       '400053', 19.1364000, 72.8296000),
(9,  'B-201, Hinjewadi Phase 1', NULL,              'Pune',         '411057', 18.5912000, 73.7389000),
(10, '23, Koramangala 4th Block', NULL,              'Bengaluru',    '560034', 12.9352000, 77.6245000);


-- ============================================================
-- 3. ENERGY SUPPLIERS
-- ============================================================

INSERT INTO energy_suppliers (supplier_name, supplier_code, contact_email, contact_phone, website, region_id) VALUES
('BSES Rajdhani Power Ltd',     'BRPL',   'support@bsesdelhi.com',     '1800-200-3000', 'https://www.bsesdelhi.com',    1),
('BSES Yamuna Power Ltd',       'BYPL',   'support@bsesyamuna.com',    '1800-200-3001', 'https://www.bsesdelhi.com',    2),
('Dakshin Haryana Bijli Vitran','DHBVN',  'support@dhbvn.org.in',      '1800-180-4040', 'https://www.dhbvn.org.in',     3),
('UP Power Corp Ltd',           'UPPCL',  'support@uppcl.org',         '1800-180-5025', 'https://www.uppcl.org',        4),
('UT Chandigarh Electricity',   'UTCE',   'support@utce.gov.in',       '0172-2740222',  'https://chdelectricity.gov.in',5),
('Jaipur Vidyut Vitran Nigam',  'JVVNL',  'support@jvvnl.com',        '1800-180-6030', 'https://www.jvvnl.com',        6),
('LESA Lucknow',                'LESA',   'support@lesa.gov.in',       '0522-2288888',  'https://www.lesa.gov.in',      7),
('Adani Electricity Mumbai',    'AEML',   'support@adanielectricity.com','1800-200-3030','https://www.adanielectricity.com',8),
('MSEDCL Pune',                 'MSEDCL', 'support@mahadiscom.in',     '1800-233-3435', 'https://www.mahadiscom.in',    9),
('BESCOM Bengaluru',            'BESCOM', 'support@bescom.co.in',      '1912',          'https://www.bescom.co.in',     10);


-- ============================================================
-- 4. CONSUMERS
-- ============================================================

INSERT INTO consumers (first_name, last_name, email, phone, consumer_type, location_id, supplier_id, account_number) VALUES
('Aarav',   'Sharma',    'aarav.sharma@email.com',    '9876543210', 'RESIDENTIAL',  1,  1,  'BRPL-RES-2024-001'),
('Priya',   'Gupta',     'priya.gupta@email.com',     '9876543211', 'RESIDENTIAL',  2,  1,  'BRPL-RES-2024-002'),
('Rohan',   'Mehta',     'rohan.mehta@email.com',      '9876543212', 'COMMERCIAL',   3,  2,  'BYPL-COM-2024-003'),
('Sneha',   'Kapoor',    'sneha.kapoor@email.com',     '9876543213', 'RESIDENTIAL',  4,  3,  'DHBVN-RES-2024-004'),
('Vikram',  'Singh',     'vikram.singh@email.com',     '9876543214', 'INDUSTRIAL',   5,  4,  'UPPCL-IND-2024-005'),
('Ananya',  'Reddy',     'ananya.reddy@email.com',     '9876543215', 'RESIDENTIAL',  6,  5,  'UTCE-RES-2024-006'),
('Karan',   'Joshi',     'karan.joshi@email.com',      '9876543216', 'COMMERCIAL',   7,  6,  'JVVNL-COM-2024-007'),
('Meera',   'Patel',     'meera.patel@email.com',      '9876543217', 'RESIDENTIAL',  8,  7,  'LESA-RES-2024-008'),
('Aditya',  'Kumar',     'aditya.kumar@email.com',     '9876543218', 'COMMERCIAL',   9,  8,  'AEML-COM-2024-009'),
('Ishita',  'Verma',     'ishita.verma@email.com',     '9876543219', 'RESIDENTIAL',  10, 9,  'MSEDCL-RES-2024-010'),
('Arjun',   'Nair',      'arjun.nair@email.com',       '9876543220', 'INDUSTRIAL',   11, 10, 'BESCOM-IND-2024-011'),
('Divya',   'Chauhan',   'divya.chauhan@email.com',    '9876543221', 'AGRICULTURAL', 1,  1,  'BRPL-AGR-2024-012'),
('Rahul',   'Tiwari',    'rahul.tiwari@email.com',     '9876543222', 'RESIDENTIAL',  3,  2,  'BYPL-RES-2024-013'),
('Pooja',   'Mishra',    'pooja.mishra@email.com',     '9876543223', 'COMMERCIAL',   5,  4,  'UPPCL-COM-2024-014'),
('Saurabh', 'Yadav',     'saurabh.yadav@email.com',    '9876543224', 'RESIDENTIAL',  7,  6,  'JVVNL-RES-2024-015');


-- ============================================================
-- 5. TARIFF PLANS
-- ============================================================

INSERT INTO tariff_plans (plan_name, plan_code, consumer_type, supplier_id, description, effective_from) VALUES
('Domestic Basic',          'DOM-BAS',  'RESIDENTIAL',  1,  'Standard residential tariff with telescopic slabs', '2025-04-01'),
('Domestic Economy',        'DOM-ECO',  'RESIDENTIAL',  1,  'Subsidized plan for low-income households',         '2025-04-01'),
('Commercial Standard',     'COM-STD',  'COMMERCIAL',   2,  'Standard tariff for commercial establishments',     '2025-04-01'),
('Industrial HT',           'IND-HT',   'INDUSTRIAL',   4,  'High-tension industrial tariff',                   '2025-04-01'),
('Agricultural Subsidized', 'AGR-SUB',  'AGRICULTURAL', 1,  'Subsidized tariff for agricultural consumers',     '2025-04-01'),
('Commercial Premium',      'COM-PRM',  'COMMERCIAL',   6,  'Premium commercial tariff with TOU pricing',       '2025-04-01'),
('Residential Smart',       'RES-SMT',  'RESIDENTIAL',  8,  'Smart meter residential with real-time pricing',   '2025-04-01'),
('Industrial LT',           'IND-LT',   'INDUSTRIAL',   10, 'Low-tension industrial tariff',                    '2025-04-01');


-- ============================================================
-- 6. TARIFF SLABS
-- ============================================================

-- Domestic Basic (Telescopic pricing)
INSERT INTO tariff_slabs (tariff_id, min_units, max_units, rate_per_unit, fixed_charge) VALUES
(1,   0,    100,  3.0000, 25.00),
(1, 100,    200,  4.5000, 50.00),
(1, 200,    400,  6.5000, 100.00),
(1, 400,   NULL,  8.0000, 150.00);

-- Domestic Economy
INSERT INTO tariff_slabs (tariff_id, min_units, max_units, rate_per_unit, fixed_charge) VALUES
(2,   0,    150,  2.0000, 0.00),
(2, 150,    300,  3.5000, 25.00),
(2, 300,   NULL,  5.5000, 50.00);

-- Commercial Standard
INSERT INTO tariff_slabs (tariff_id, min_units, max_units, rate_per_unit, fixed_charge) VALUES
(3,   0,    500,  7.5000, 200.00),
(3, 500,   1000,  8.5000, 350.00),
(3,1000,   NULL,  9.5000, 500.00);

-- Industrial HT
INSERT INTO tariff_slabs (tariff_id, min_units, max_units, rate_per_unit, fixed_charge) VALUES
(4,    0,   5000, 6.0000, 1500.00),
(4, 5000,  20000, 5.5000, 3000.00),
(4,20000,   NULL, 5.0000, 5000.00);

-- Agricultural Subsidized
INSERT INTO tariff_slabs (tariff_id, min_units, max_units, rate_per_unit, fixed_charge) VALUES
(5,   0,   NULL,  1.5000, 0.00);


-- ============================================================
-- 7. METERS
-- ============================================================

INSERT INTO meters (meter_serial, meter_type, manufacturer, model, firmware_ver, consumer_id, location_id, tariff_id, installation_date, last_calibration, status, communication) VALUES
('SM-DEL-2024-00001', 'SINGLE_PHASE', 'Genus Power',       'GEN-S100',  'v3.2.1', 1,  1,  1, '2024-06-15', '2025-06-15', 'ACTIVE', 'RF'),
('SM-DEL-2024-00002', 'SINGLE_PHASE', 'Genus Power',       'GEN-S100',  'v3.2.1', 2,  2,  1, '2024-07-01', '2025-07-01', 'ACTIVE', 'RF'),
('SM-DEL-2024-00003', 'THREE_PHASE',  'HPL Electric',      'HPL-T300',  'v2.8.0', 3,  3,  3, '2024-05-20', '2025-05-20', 'ACTIVE', 'GPRS'),
('SM-GGN-2024-00004', 'SINGLE_PHASE', 'Secure Meters',     'SEC-S200',  'v4.1.0', 4,  4,  1, '2024-08-10', NULL,         'ACTIVE', 'NB_IOT'),
('SM-NOI-2024-00005', 'THREE_PHASE',  'L&T Electrical',    'LT-T500',   'v5.0.2', 5,  5,  4, '2024-03-25', '2025-03-25', 'ACTIVE', 'GPRS'),
('SM-CHD-2024-00006', 'SINGLE_PHASE', 'Genus Power',       'GEN-S100',  'v3.2.1', 6,  6,  2, '2024-09-01', NULL,         'ACTIVE', 'LORA'),
('SM-JAI-2024-00007', 'THREE_PHASE',  'HPL Electric',      'HPL-T300',  'v2.8.0', 7,  7,  6, '2024-04-15', '2025-04-15', 'ACTIVE', 'GPRS'),
('SM-LKO-2024-00008', 'SINGLE_PHASE', 'Secure Meters',     'SEC-S200',  'v4.1.0', 8,  8,  2, '2024-10-20', NULL,         'ACTIVE', 'WIFI'),
('SM-MUM-2024-00009', 'THREE_PHASE',  'Schneider Electric', 'SCH-T700', 'v6.1.3', 9,  9,  7, '2024-02-14', '2025-02-14', 'ACTIVE', 'NB_IOT'),
('SM-PUN-2024-00010', 'SINGLE_PHASE', 'L&T Electrical',    'LT-S300',  'v5.0.2', 10, 10, 1, '2024-11-05', NULL,         'ACTIVE', 'RF'),
('SM-BLR-2024-00011', 'THREE_PHASE',  'Schneider Electric', 'SCH-T700', 'v6.1.3', 11, 11, 8, '2024-01-10', '2025-01-10', 'ACTIVE', 'GPRS'),
('SM-DEL-2024-00012', 'NET_METER',    'Genus Power',       'GEN-N200',  'v3.3.0', 12, 1,  5, '2024-12-01', NULL,         'ACTIVE', 'LORA'),
('SM-DEL-2024-00013', 'SINGLE_PHASE', 'HPL Electric',      'HPL-S100',  'v2.9.0', 13, 3,  1, '2025-01-15', NULL,         'ACTIVE', 'RF'),
('SM-NOI-2024-00014', 'THREE_PHASE',  'L&T Electrical',    'LT-T500',   'v5.0.2', 14, 5,  3, '2025-02-01', NULL,         'ACTIVE', 'GPRS'),
('SM-JAI-2024-00015', 'PREPAID',      'Secure Meters',     'SEC-P100',  'v4.2.0', 15, 7,  2, '2025-03-01', NULL,         'ACTIVE', 'NB_IOT');


-- ============================================================
-- 8. METER READINGS (simulated hourly data for a few days)
-- ============================================================

-- Meter 1 readings (residential, ~8-10 kWh/day)
INSERT INTO meter_readings (meter_id, reading_time, energy_kwh, power_kw, voltage_v, current_a, frequency_hz, power_factor) VALUES
(1, '2026-03-01 00:00:00', 15000.0000, 0.3500, 230.50, 1.52, 50.01, 0.950),
(1, '2026-03-01 06:00:00', 15001.5000, 0.4200, 231.20, 1.82, 50.00, 0.960),
(1, '2026-03-01 12:00:00', 15005.8000, 1.5000, 228.80, 6.55, 49.98, 0.970),
(1, '2026-03-01 18:00:00', 15008.2000, 1.8000, 227.50, 7.91, 49.99, 0.960),
(1, '2026-03-02 00:00:00', 15010.0000, 0.3000, 230.00, 1.30, 50.00, 0.950),
(1, '2026-03-02 06:00:00', 15011.2000, 0.4000, 231.50, 1.73, 50.01, 0.960),
(1, '2026-03-02 12:00:00', 15015.5000, 1.6000, 229.00, 6.99, 49.98, 0.970),
(1, '2026-03-02 18:00:00', 15018.1000, 1.9500, 226.80, 8.61, 49.97, 0.955),
(1, '2026-03-03 00:00:00', 15020.0000, 0.2800, 230.20, 1.22, 50.00, 0.950),
(1, '2026-03-31 23:59:59', 15310.5000, 0.4000, 230.00, 1.74, 50.00, 0.960);

-- Meter 3 readings (commercial, higher usage ~50 kWh/day)
INSERT INTO meter_readings (meter_id, reading_time, energy_kwh, power_kw, voltage_v, current_a, frequency_hz, power_factor) VALUES
(3, '2026-03-01 00:00:00', 85000.0000, 2.5000, 415.00, 3.48, 50.00, 0.920),
(3, '2026-03-01 08:00:00', 85010.0000, 8.5000, 412.50, 11.90, 49.99, 0.940),
(3, '2026-03-01 16:00:00', 85045.0000, 9.2000, 413.80, 12.85, 50.01, 0.935),
(3, '2026-03-02 00:00:00', 85055.0000, 2.0000, 414.20, 2.79, 50.00, 0.915),
(3, '2026-03-02 08:00:00', 85065.0000, 8.8000, 412.00, 12.34, 49.98, 0.940),
(3, '2026-03-02 16:00:00', 85100.0000, 9.5000, 413.50, 13.28, 50.00, 0.938),
(3, '2026-03-03 00:00:00', 85110.0000, 1.8000, 414.80, 2.51, 50.01, 0.920),
(3, '2026-03-31 23:59:59', 86550.0000, 2.2000, 414.00, 3.07, 50.00, 0.925);

-- Meter 5 readings (industrial, ~500 kWh/day)
INSERT INTO meter_readings (meter_id, reading_time, energy_kwh, power_kw, voltage_v, current_a, frequency_hz, power_factor) VALUES
(5, '2026-03-01 00:00:00', 500000.0000, 15.0000, 11000.00, 0.79, 50.00, 0.880),
(5, '2026-03-01 08:00:00', 500120.0000, 45.0000, 10950.00, 2.37, 49.99, 0.920),
(5, '2026-03-01 16:00:00', 500380.0000, 50.0000, 10980.00, 2.63, 50.01, 0.915),
(5, '2026-03-02 00:00:00', 500500.0000, 10.0000, 11020.00, 0.52, 50.00, 0.870),
(5, '2026-03-31 23:59:59', 515500.0000, 12.0000, 11000.00, 0.63, 50.00, 0.880);


-- ============================================================
-- 9. DAILY CONSUMPTION
-- ============================================================

INSERT INTO daily_consumption (meter_id, consumption_date, total_kwh, peak_kwh, off_peak_kwh, max_demand_kw, avg_voltage, avg_power_factor) VALUES
-- Meter 1 (Residential)
(1, '2026-03-01', 10.0000, 6.5000, 3.5000, 1.8000, 229.50, 0.960),
(1, '2026-03-02', 10.0000, 6.8000, 3.2000, 1.9500, 229.33, 0.958),
(1, '2026-03-03',  9.5000, 6.0000, 3.5000, 1.7000, 230.10, 0.962),
(1, '2026-03-04', 10.2000, 6.9000, 3.3000, 2.0000, 228.90, 0.955),
(1, '2026-03-05',  9.8000, 6.3000, 3.5000, 1.8500, 229.80, 0.960),
-- Meter 3 (Commercial)
(3, '2026-03-01', 55.0000, 38.0000, 17.0000, 9.2000, 413.43, 0.932),
(3, '2026-03-02', 55.0000, 39.5000, 15.5000, 9.5000, 413.23, 0.931),
(3, '2026-03-03', 48.0000, 32.0000, 16.0000, 8.5000, 414.00, 0.938),
(3, '2026-03-04', 52.0000, 36.0000, 16.0000, 9.0000, 413.60, 0.935),
(3, '2026-03-05', 56.5000, 40.0000, 16.5000, 9.8000, 412.90, 0.928),
-- Meter 5 (Industrial)
(5, '2026-03-01', 500.0000, 320.0000, 180.0000, 50.0000, 10976.67, 0.905),
(5, '2026-03-02', 480.0000, 300.0000, 180.0000, 48.0000, 10990.00, 0.910),
(5, '2026-03-03', 520.0000, 340.0000, 180.0000, 52.0000, 10960.00, 0.900),
(5, '2026-03-04', 510.0000, 330.0000, 180.0000, 51.0000, 10975.00, 0.908),
(5, '2026-03-05', 490.0000, 310.0000, 180.0000, 49.0000, 10985.00, 0.912);


-- ============================================================
-- 10. BILLS
-- ============================================================

INSERT INTO bills (bill_number, consumer_id, meter_id, billing_period_start, billing_period_end, previous_reading, current_reading, units_consumed, energy_charge, fixed_charge, demand_charge, tax_amount, surcharge, subsidy, total_amount, due_date, bill_status) VALUES
('BILL-001-202603', 1,  1,  '2026-03-01', '2026-03-31', 15000.0000, 15310.5000, 310.5000, 1740.75, 175.00, 0.00,   95.79, 0.00,  0.00, 2011.54, '2026-04-15', 'SENT'),
('BILL-003-202603', 3,  3,  '2026-03-01', '2026-03-31', 85000.0000, 86550.0000, 1550.0000, 13425.00, 850.00, 500.00, 738.75, 150.00, 0.00, 15663.75, '2026-04-15', 'SENT'),
('BILL-005-202603', 5,  5,  '2026-03-01', '2026-03-31', 500000.0000, 515500.0000, 15500.0000, 87750.00, 4500.00, 2500.00, 4737.50, 500.00, 0.00, 99987.50, '2026-04-15', 'GENERATED'),
('BILL-001-202602', 1,  1,  '2026-02-01', '2026-02-28', 14720.0000, 15000.0000, 280.0000, 1560.00, 175.00, 0.00,   86.75, 0.00,  0.00, 1821.75, '2026-03-15', 'PAID'),
('BILL-003-202602', 3,  3,  '2026-02-01', '2026-02-28', 83400.0000, 85000.0000, 1600.0000, 13900.00, 850.00, 500.00, 762.50, 150.00, 0.00, 16162.50, '2026-03-15', 'PAID');


-- ============================================================
-- 11. PAYMENTS
-- ============================================================

INSERT INTO payments (payment_ref, bill_id, consumer_id, amount_paid, payment_method, payment_date, transaction_id, payment_status) VALUES
('PAY-4-20260310120000', 4, 1, 1821.75, 'UPI',         '2026-03-10 12:00:00', 'UPI-TXN-98765432', 'SUCCESS'),
('PAY-5-20260312143000', 5, 3, 16162.50, 'NETBANKING', '2026-03-12 14:30:00', 'NB-TXN-12345678',  'SUCCESS');


-- ============================================================
-- 12. PREPAID WALLETS
-- ============================================================

INSERT INTO prepaid_wallets (consumer_id, balance, low_balance_threshold, auto_recharge, last_recharged) VALUES
(15, 850.00, 200.00, TRUE, '2026-03-25 10:00:00');

INSERT INTO wallet_transactions (wallet_id, txn_type, amount, balance_after, description, txn_time) VALUES
(1, 'RECHARGE',  1000.00, 1000.00, 'Initial recharge via UPI',       '2026-03-01 10:00:00'),
(1, 'DEDUCTION',   50.00,  950.00, 'Daily consumption deduction',    '2026-03-10 00:00:00'),
(1, 'DEDUCTION',   50.00,  900.00, 'Daily consumption deduction',    '2026-03-20 00:00:00'),
(1, 'DEDUCTION',   50.00,  850.00, 'Daily consumption deduction',    '2026-03-25 00:00:00');


-- ============================================================
-- 13. ALERTS
-- ============================================================

INSERT INTO alerts (meter_id, consumer_id, alert_type, severity, message, is_read, is_resolved, triggered_at) VALUES
(5,  5,  'OVERLOAD',       'CRITICAL', 'Demand exceeded 50 kW — possible overload detected on meter SM-NOI-2024-00005.',  FALSE, FALSE, '2026-03-01 14:30:00'),
(1,  1,  'HIGH_USAGE',     'WARNING',  'Daily consumption 30% higher than 7-day average for meter SM-DEL-2024-00001.',    FALSE, FALSE, '2026-03-04 08:00:00'),
(7,  7,  'LOW_VOLTAGE',    'WARNING',  'Average voltage dropped below 200V for meter SM-JAI-2024-00007.',                 TRUE,  TRUE,  '2026-03-02 22:15:00'),
(9,  9,  'TAMPER_DETECT',  'CRITICAL', 'Tamper event detected on meter SM-MUM-2024-00009. Enclosure opened.',             FALSE, FALSE, '2026-03-05 03:45:00'),
(15, 15, 'LOW_BALANCE',    'WARNING',  'Prepaid balance is ₹850.00. Threshold: ₹200.00.',                                FALSE, FALSE, '2026-03-25 00:05:00'),
(3,  3,  'ABNORMAL_PATTERN','INFO',    'Unusual off-peak consumption pattern on meter SM-DEL-2024-00003.',                FALSE, FALSE, '2026-03-06 06:00:00');


-- ============================================================
-- 14. METER EVENTS
-- ============================================================

INSERT INTO meter_events (meter_id, event_type, event_time, details) VALUES
(1,  'POWER_ON',          '2024-06-15 10:00:00', '{"reason": "new_installation"}'),
(3,  'FIRMWARE_UPDATE',   '2025-01-20 02:00:00', '{"from": "v2.7.0", "to": "v2.8.0"}'),
(5,  'OVERLOAD',          '2026-03-01 14:30:00', '{"demand_kw": 52.5, "threshold_kw": 50.0}'),
(7,  'COMMUNICATION_LOSS','2026-03-02 22:00:00', '{"duration_min": 45}'),
(7,  'COMMUNICATION_RESTORE', '2026-03-02 22:45:00', '{"auto_restored": true}'),
(9,  'TAMPER_OPEN',       '2026-03-05 03:45:00', '{"sensor": "magnetic", "location": "terminal_cover"}'),
(15, 'POWER_ON',          '2025-03-01 09:00:00', '{"reason": "new_installation"}'),
(1,  'CALIBRATION',       '2025-06-15 11:00:00', '{"technician": "Rajesh Kumar", "accuracy": 99.8}');


-- ============================================================
-- 15. SERVICE REQUESTS
-- ============================================================

INSERT INTO service_requests (request_number, consumer_id, meter_id, request_type, priority, description, status, assigned_to, resolution_notes) VALUES
('SR-2026-0001', 9,  9,  'METER_TESTING',    'HIGH',   'Consumer reports inaccurate readings. Meter tamper alert triggered.', 'IN_PROGRESS', 'Rajesh Kumar',  NULL),
('SR-2026-0002', 1,  1,  'BILLING_DISPUTE',  'MEDIUM', 'Consumer disputes March bill. Claims readings are too high.',         'OPEN',        NULL,            NULL),
('SR-2026-0003', 7,  7,  'METER_REPLACEMENT','MEDIUM', 'Frequent communication loss. Recommend meter replacement.',           'RESOLVED',    'Amit Verma',    'Replaced meter. New serial: SM-JAI-2025-00016.'),
('SR-2026-0004', 4,  NULL,'TARIFF_CHANGE',    'LOW',    'Consumer requests switch to time-of-use tariff plan.',                'OPEN',        NULL,            NULL),
('SR-2026-0005', 15, 15, 'GENERAL_INQUIRY',  'LOW',    'Consumer wants to set up auto-recharge for prepaid meter.',           'CLOSED',      'Pradeep Singh', 'Auto-recharge enabled via portal.');


-- ============================================================
-- 16. OUTAGES
-- ============================================================

INSERT INTO outages (region_id, outage_type, cause, affected_meters, started_at, estimated_restore, restored_at, status, notes) VALUES
(6, 'UNPLANNED', 'Transformer failure at Sub-Station 12', 450, '2026-03-02 21:30:00', '2026-03-03 03:00:00', '2026-03-03 02:15:00', 'RESTORED', 'Replacement transformer installed.'),
(1, 'PLANNED',   'Scheduled maintenance on 33kV feeder',  200, '2026-04-15 09:00:00', '2026-04-15 17:00:00', NULL,                   'ONGOING',  'Advance notice sent to consumers.'),
(8, 'EMERGENCY', 'Cyclone damage to transmission lines',  1200,'2026-02-20 18:00:00', '2026-02-22 00:00:00', '2026-02-21 22:30:00', 'RESTORED', 'Emergency crew deployed within 1 hour.');


-- ============================================================
-- End of Seed Data
-- ============================================================
