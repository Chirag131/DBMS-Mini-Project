# ⚡ Smart Energy Metering Database

A comprehensive **MariaDB** database for Smart Energy Metering systems — covering everything from consumer management and smart meter tracking to real-time consumption analytics, automated billing, prepaid wallets, and outage monitoring.

---

## 📋 Table of Contents

- [Overview](#overview)
- [ER Diagram](#er-diagram)
- [Database Schema](#database-schema)
- [Setup Instructions](#setup-instructions)
- [File Structure](#file-structure)
- [Key Features](#key-features)
- [Sample Queries](#sample-queries)
- [Tech Stack](#tech-stack)
- [License](#license)

---

## Overview

The **Smart Energy Metering Database** is designed to support the complete lifecycle of a smart energy metering system:

| Module                  | Description                                                    |
|-------------------------|----------------------------------------------------------------|
| **Consumer Management** | Track residential, commercial, industrial & agricultural users |
| **Meter Management**    | Single-phase, three-phase, prepaid, and net metering support   |
| **Real-Time Readings**  | Time-series data with voltage, current, power factor logging   |
| **Tariff Engine**       | Telescopic slab-based pricing with multi-tier rate plans       |
| **Automated Billing**   | Stored procedures for bill generation and payment processing   |
| **Prepaid System**      | Wallet-based prepaid metering with auto-recharge support       |
| **Alerts & Events**     | Tamper detection, overload, outage, and low-balance alerts     |
| **Outage Tracking**     | Planned/unplanned outage management with affected meter counts |
| **Service Requests**    | Ticketing system for meter issues, billing disputes, etc.      |
| **Audit Trail**         | Complete audit logging with JSON change tracking               |

---

## ER Diagram

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│   regions    │────▶│  locations   │◀────│    consumers     │
└──────────────┘     └──────────────┘     └──────────────────┘
       │                    │                  │         │
       │                    │                  │         │
       ▼                    ▼                  ▼         ▼
┌──────────────┐     ┌──────────────┐   ┌──────────┐ ┌──────────────────┐
│   outages    │     │    meters    │   │  bills   │ │ energy_suppliers │
└──────────────┘     └──────────────┘   └──────────┘ └──────────────────┘
                       │    │    │           │                 │
                 ┌─────┘    │    └──────┐    │                 │
                 ▼          ▼          ▼    ▼                 ▼
          ┌────────────┐ ┌────────┐ ┌────────────┐    ┌──────────────┐
          │  readings  │ │ events │ │  alerts    │    │ tariff_plans │
          └────────────┘ └────────┘ └────────────┘    └──────────────┘
                 │                                          │
                 ▼                                          ▼
          ┌────────────────┐                         ┌──────────────┐
          │daily_consumption│                         │ tariff_slabs │
          └────────────────┘                         └──────────────┘
                                    ┌──────────┐
                         bills ────▶│ payments │
                                    └──────────┘
                                    ┌──────────────────┐
                      consumers ───▶│ prepaid_wallets   │
                                    └──────────────────┘
                                          │
                                          ▼
                                    ┌──────────────────────┐
                                    │ wallet_transactions  │
                                    └──────────────────────┘
```

---

## Database Schema

### Tables (15)

| #  | Table                   | Purpose                                         |
|----|-------------------------|-------------------------------------------------|
| 1  | `regions`               | Geographic regions / distribution circles        |
| 2  | `locations`             | Physical addresses with GPS coordinates          |
| 3  | `energy_suppliers`      | Electricity distribution companies               |
| 4  | `consumers`             | End-users / customers                            |
| 5  | `tariff_plans`          | Rate plan definitions per consumer type          |
| 6  | `tariff_slabs`          | Telescopic pricing slabs within a tariff plan    |
| 7  | `meters`                | Smart meter devices and their configurations     |
| 8  | `meter_readings`        | Time-series energy readings (kWh, V, A, PF)      |
| 9  | `daily_consumption`     | Pre-aggregated daily consumption summaries       |
| 10 | `bills`                 | Generated electricity bills                      |
| 11 | `payments`              | Payment transactions against bills               |
| 12 | `prepaid_wallets`       | Prepaid balance tracking per consumer            |
| 13 | `wallet_transactions`   | Recharge, deduction & refund log for wallets     |
| 14 | `alerts`                | System-generated alerts and notifications        |
| 15 | `meter_events`          | Hardware events (tamper, firmware, power on/off)  |
| 16 | `service_requests`      | Consumer service tickets                         |
| 17 | `outages`               | Power outage tracking per region                 |
| 18 | `audit_log`             | System-level change audit trail (JSON-based)     |

### Views (4)

| View                         | Purpose                                    |
|------------------------------|--------------------------------------------|
| `vw_consumer_billing_summary`| Consumer-wise billing & payment summary    |
| `vw_monthly_consumption`    | Monthly aggregated consumption per meter   |
| `vw_active_alerts`          | Dashboard view of unresolved alerts        |
| `vw_revenue_by_region`      | Revenue collection analysis per region     |

### Stored Procedures (3)

| Procedure                   | Purpose                                     |
|-----------------------------|---------------------------------------------|
| `sp_generate_bill`          | Auto-calculate & generate a bill for a meter|
| `sp_consumption_analytics`  | Get consumption trends for N months         |
| `sp_record_payment`         | Record payment and auto-update bill status  |

### Triggers (3)

| Trigger                     | Purpose                                     |
|-----------------------------|---------------------------------------------|
| `trg_bill_overdue_alert`    | Auto-create alert when bill becomes overdue |
| `trg_wallet_low_balance`    | Alert when prepaid balance falls below limit|
| `trg_meter_status_audit`    | Log meter status changes to audit table     |

---

## Setup Instructions

### Prerequisites

- **MariaDB 10.6+** installed and running
- A MariaDB client (CLI, DBeaver, HeidiSQL, phpMyAdmin, etc.)

### Step 1: Create the Database & Schema

```bash
mysql -u root -p < schema.sql
```

### Step 2: Load Sample Data

```bash
mysql -u root -p < seed_data.sql
```

### Step 3: Run Sample Queries (Optional)

```bash
mysql -u root -p smart_energy_metering < queries.sql
```

### Quick Verification

```sql
USE smart_energy_metering;

-- Check all tables are created
SHOW TABLES;

-- Verify data loaded
SELECT COUNT(*) AS total_consumers FROM consumers;
SELECT COUNT(*) AS total_meters FROM meters;
SELECT COUNT(*) AS total_readings FROM meter_readings;

-- Test a view
SELECT * FROM vw_active_alerts;

-- Test a stored procedure
CALL sp_consumption_analytics(1, 6);
```

---

## File Structure

```
DBMS/
├── schema.sql          # Complete database schema (tables, views, SPs, triggers)
├── seed_data.sql       # Sample data for all tables
├── queries.sql         # 20 production-ready analytical queries
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

---

## Key Features

- **🔌 Smart Meter Support** — Single-phase, three-phase, prepaid, and net metering
- **📊 Real-Time Analytics** — Time-series readings with voltage, current, power factor
- **💰 Automated Billing** — Stored procedure for slab-based bill calculation
- **🔔 Smart Alerts** — Tamper detection, overload, low voltage, and anomaly alerts
- **💳 Prepaid Metering** — Wallet system with recharge, deductions, and auto-recharge
- **🛠 Service Management** — Ticketing system for consumer requests and complaints
- **⚡ Outage Tracking** — Planned/unplanned outage monitoring with region impact
- **📝 Full Audit Trail** — JSON-based change logging for compliance
- **🏗 Proper Indexing** — Optimized indexes for analytical query performance
- **🔐 Referential Integrity** — Foreign keys with appropriate CASCADE/RESTRICT rules

---

## Sample Queries

The `queries.sql` file contains **20 ready-to-use queries** organized into:

1. **Consumer Queries** — Active consumers, outstanding balances, search
2. **Consumption Analytics** — Top consumers, daily trends, peak vs off-peak
3. **Billing & Revenue** — Monthly revenue, payment method analysis
4. **Meter Infrastructure** — Inventory, calibration due, communication issues
5. **Alerts & Events** — Critical alerts, resolution metrics
6. **Outage Analysis** — Duration, affected areas, history
7. **Dashboard Queries** — System-wide KPIs, health metrics

---

## Tech Stack

| Component   | Technology     |
|-------------|----------------|
| DBMS        | MariaDB 10.6+  |
| Engine      | InnoDB         |
| Charset     | utf8mb4        |
| Collation   | utf8mb4_unicode_ci |

---

## License

This project is open-source and available under the [MIT License](LICENSE).

---

**Made with ❤️ by Chirag Tuteja**
