import pandas as pd
import numpy as np
import os

# --- 1. INFRASTRUCTURE SETUP ---
# Defining paths on the C: drive to optimize I/O performance and avoid sync locks.
input_file = r'C:\FinTech_Project\Data\paysim_data.csv'
output_dir = r'C:\FinTech_Project\output'

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# --- 2. DATA INGESTION & OPTIMIZATION ---
print("START: Ingesting source telemetry (paysim_data.csv)...")
df = pd.read_csv(input_file)

# We sub-sample to 100,000 records to maintain a high-velocity development cycle
# while preserving statistically significant fraud patterns.
print("STEP: Sampling 100,000 records for performance-tuned development...")
df = df.sample(n=100000, random_state=42).reset_index(drop=True)

# --- 3. ARCHITECTURAL NORMALIZATION (Snowflake Schema) ---
# Transitioning from a flat-file structure to a Relational Model.
print("STEP: Architecting Dimension Tables (Customers & Devices)...")
unique_customers = df['nameOrig'].unique()

# dim_customers: Captures PII proxies and regional risk segments.
dim_customers = pd.DataFrame({
    'customer_id': unique_customers,
    'home_lat': np.random.uniform(-1.3, -1.5, len(unique_customers)),
    'home_lon': np.random.uniform(36.7, 36.9, len(unique_customers)),
    'risk_segment': np.random.choice(['Standard', 'High-Value', 'New-User'], len(unique_customers))
})

# dim_devices: Simulates hardware telemetry to identify high-risk (rooted) endpoints.
dim_devices = pd.DataFrame({
    'customer_id': np.random.choice(unique_customers, len(unique_customers)),
    'device_id': [f"DEV_{i}" for i in range(len(unique_customers))],
    'device_type': np.random.choice(['Android', 'iOS'], len(unique_customers)),
    'is_rooted': np.random.choice([0, 1], len(unique_customers), p=[0.95, 0.05])
})

# --- 4. BEHAVIORAL FEATURE ENGINEERING ---
# Developing advanced risk signals to power the downstream detection engine.
print("STEP: Engineering Risk Signals (Velocity & Amount Deviation)...")

# Transaction Velocity: Calculating time-deltas between sequential events.
df = df.sort_values(by=['nameOrig', 'step'])
df['time_since_last_tx'] = df.groupby('nameOrig')['step'].diff().fillna(0)

# Amount Deviation: Identifying outliers by comparing current spend against historical mean.
df['avg_tx_amount'] = df.groupby('nameOrig')['amount'].transform('mean')
df['amt_deviation_ratio'] = df['amount'] / df['avg_tx_amount']
df['is_high_deviation'] = np.where(df['amt_deviation_ratio'] > 3, 1, 0)

# --- 5. FACT TABLE CONSTRUCTION ---
# Finalizing the Fact Table with enriched features for analytical modeling.
fact_transactions = df[[
    'step', 'type', 'amount', 'nameOrig', 'oldbalanceOrg', 'newbalanceOrig',
    'nameDest', 'oldbalanceDest', 'newbalanceDest', 'isFraud',
    'time_since_last_tx', 'avg_tx_amount', 'is_high_deviation'
]]

# --- 6. DATA EXPORT ---
print(r"STEP: Persisting normalized assets to C:\FinTech_Project\output...")
dim_customers.to_csv(os.path.join(
    output_dir, 'dim_customers.csv'), index=False)
dim_devices.to_csv(os.path.join(output_dir, 'dim_devices.csv'), index=False)
fact_transactions.to_csv(os.path.join(
    output_dir, 'fact_transactions.csv'), index=False)

print("FINISH: Stage 1 Complete. Relational assets are ready for SQL ingestion.")
