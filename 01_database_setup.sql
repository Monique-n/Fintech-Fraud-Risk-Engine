CREATE DATABASE fintech_fraud_db;
USE fintech_fraud_db;

-- 1. Customers Dimension (Unique Senders)
CREATE TABLE dim_customers (
customer_id VARCHAR(50) PRIMARY KEY,
home_lat double,
home_lon double,
risk_segment VARCHAR(20),
INDEX (risk_segment) -- Performance Index
);

-- 1. Devices Dimension (Hardware Telemetry)
CREATE TABLE dim_devices (
    customer_id VARCHAR(50),
    device_id VARCHAR(50) PRIMARY KEY,
    device_type VARCHAR(20),
    is_rooted INT,
    INDEX (is_rooted)
) ENGINE=InnoDB -- This tells MySQL to use a modern storage engine that supports "Transactions" (making sure data isn't lost if the power goes out) 
;

-- 2. Transactions Fact Table 
CREATE TABLE fact_transactions (
    step INT,
    type VARCHAR(20),
    amount DECIMAL(15, 2),
    nameOrig VARCHAR(50),
    oldbalanceOrg DECIMAL(15, 2),
    newbalanceOrig DECIMAL(15, 2),
    nameDest VARCHAR(50),
    device_id VARCHAR(50), 
    oldbalanceDest DECIMAL(15, 2),
    newbalanceDest DECIMAL(15, 2),
    isFraud INT,
    time_since_last_tx FLOAT,
    avg_tx_amount DOUBLE,
    is_high_deviation INT,
    INDEX (nameOrig),
    INDEX (isFraud),
    INDEX (device_id) 
) ENGINE=InnoDB;

-- 3. DATA INGESTION
TRUNCATE TABLE dim_devices; 
INSERT INTO dim_devices (customer_id, device_id, device_type, is_rooted)
SELECT 
    customer_id, 
    CONCAT('DEV_', customer_id), 
    IF(RAND() > 0.5, 'Android', 'iOS'), 
    IF(RAND() > 0.95, 1, 0) 
FROM dim_customers;

-- Now "Wire" the fact table to the newly created devices
SET SQL_SAFE_UPDATES = 0;
UPDATE fact_transactions f
JOIN dim_devices d ON f.nameOrig = d.customer_id
SET f.device_id = d.device_id;


-- Allow the database to read local files
SET GLOBAL local_infile = 1;

-- We modify the columns to DOUBLE to accept high-precision Python floats
ALTER TABLE dim_customers
MODIFY COLUMN home_lat DOUBLE,
MODIFY COLUMN home_lon DOUBLE;

-- Clear the 'bad' data from the previous attempt
TRUNCATE TABLE dim_customers;
-- Load Customers
LOAD DATA LOCAL INFILE 'C:/FinTech_Project/output/dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 1. Clear the table completely
TRUNCATE TABLE dim_devices;
-- Load Devices
LOAD DATA LOCAL INFILE 'C:/FinTech_Project/output/dim_devices.csv'
INTO TABLE dim_devices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 1. Upgrade the column to handle high-precision floating points
ALTER TABLE fact_transactions
MODIFY COLUMN avg_tx_amount DOUBLE;
-- 2. Clear the table to ensure a clean re-load
TRUNCATE TABLE fact_transactions;

-- Load Transactions (The Fact Table)
LOAD DATA LOCAL INFILE 'C:/FinTech_Project/output/fact_transactions.csv'
INTO TABLE fact_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(step, type, amount, nameOrig, oldbalanceOrg, newbalanceOrig, nameDest, 
 oldbalanceDest, newbalanceDest, isFraud, time_since_last_tx, avg_tx_amount, is_high_deviation);
 -- Note: We omit 'device_id' from this list because it's not in the CSV!

-- Final Check: Ensuring row counts match the source CSVs
SELECT 'dim_customers' AS table_name, COUNT(*) AS total FROM dim_customers
UNION ALL
SELECT 'dim_devices', COUNT(*) FROM dim_devices
UNION ALL
SELECT 'fact_transactions', COUNT(*) FROM fact_transactions;

SELECT
f.nameOrig AS Customer_ID,
f.type AS Tx_Type,
f.amount,
f.avg_tx_amount AS User_Avg,
c.risk_segment,
d.device_type,
d.is_rooted
FROM fact_transactions f
JOIN dim_customers c ON f.nameOrig = c.customer_id
JOIN dim_devices d ON f.nameOrig = d.customer_id
WHERE d.is_rooted = 1
AND f.is_high_deviation = 1
AND c.risk_segment = 'High'
ORDER BY f.amount DESC;


-- 1. TEMPORARILY LIFT CONSTRAINTS to allow the cleanup
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE dim_devices;

-- 2. RE-ENGINEER THE DEVICE TABLE (1-to-1 Mapping)
-- Instead of random sampling, we ensure every customer has a device.
INSERT INTO dim_devices (customer_id, device_id, device_type, is_rooted)
SELECT 
    customer_id, 
    CONCAT('DEV_', customer_id), -- Create a unique device ID per customer
    IF(RAND() > 0.5, 'Android', 'iOS'), -- Maintain the 50/50 split
    IF(RAND() > 0.95, 1, 0) -- Maintain the 5% rooted risk profile
FROM dim_customers;

-- 3. RE-WIRE THE TRANSACTIONS
-- Now every nameOrig will find a match in dim_devices
UPDATE fact_transactions f
JOIN dim_devices d ON f.nameOrig = d.customer_id
SET f.device_id = d.device_id;

-- 4. RESTORE CONSTRAINTS
SET FOREIGN_KEY_CHECKS = 1;

-- 5. FINAL SUCCESS AUDIT
SELECT 'dim_customers' AS table_name, COUNT(*) AS total FROM dim_customers
UNION ALL
SELECT 'dim_devices', COUNT(*) FROM dim_devices
UNION ALL
SELECT 'fact_transactions', COUNT(*) FROM fact_transactions;


SELECT COUNT(*) AS unlinked_transactions 
FROM fact_transactions 
WHERE device_id IS NULL;