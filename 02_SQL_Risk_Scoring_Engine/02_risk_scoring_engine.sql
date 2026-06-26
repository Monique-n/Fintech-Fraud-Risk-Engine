/* =============================================================================
STRATEGIC RISK ARCHITECTURE
Target: High Detection with Low Customer Friction
=============================================================================
*/

--  THE ENGINE: Centralized Risk Scoring View
-- This serves as our "Truth Source" where we define the weight of each red flag.
CREATE OR REPLACE VIEW v_fraud_rule_engine AS
SELECT 
    f.*,
    -- Rule 1: High Risk Types (Base Risk for money leaving the system)
    CASE WHEN f.type IN ('TRANSFER', 'CASH_OUT') THEN 40 ELSE 0 END AS pts_type,
    
    -- Rule 2: Velocity (Aggressive timing between transactions)
    CASE WHEN f.time_since_last_tx < 1 THEN 15 ELSE 0 END AS pts_velocity,
    
    -- Rule 3: Hardware Risk (Rooted/Tampered devices)
    CASE WHEN d.is_rooted = 1 THEN 20 ELSE 0 END AS pts_device,
    
    -- Rule 4: Deviation (Transactions significantly higher than user average)
    CASE WHEN f.is_high_deviation = 1 THEN 40 ELSE 0 END AS pts_deviation
FROM fact_transactions f
LEFT JOIN dim_devices d ON f.device_id = d.device_id;


--  THE DASHBOARD: High-Level KPI Pulse Checks
-- Overall Fraud Prevalence: Are we facing a surge in attacks?
SELECT 
    COUNT(*) AS total_transactions,
    SUM(isFraud) AS total_fraud_incidents,
    ROUND(SUM(isFraud) / COUNT(*) * 100, 4) AS fraud_rate_pct
FROM v_fraud_rule_engine;

-- Category Risk Analysis: Confirming the 10x risk of Outflow vs Inflow
SELECT 
    CASE 
        WHEN type IN ('TRANSFER', 'CASH_OUT') THEN '🔴 HIGH_RISK_OUTFLOW'
        ELSE '🟢 LOW_RISK_INFLOW'
    END AS transaction_category,
    COUNT(*) AS volume,
    SUM(isFraud) AS caught_fraud,
    ROUND(SUM(isFraud) / COUNT(*) * 100, 3) AS fraud_rate_pct
FROM fact_transactions
GROUP BY 1;

--  THE AUDIT: Individual Rule Precision
-- We check if individual signals are "Smart" or just "Noisy."
SELECT 
    'Velocity Rule' AS rule_name,
    COUNT(*) AS times_triggered,
    SUM(isFraud) AS fraud_captured,
    ROUND(SUM(isFraud) / COUNT(*) * 100, 4) AS rule_precision_pct
FROM v_fraud_rule_engine WHERE pts_velocity > 0
UNION ALL
SELECT 
    'Device Integrity Rule',
    COUNT(*) AS times_triggered,
    SUM(isFraud) AS fraud_captured,
    ROUND(SUM(isFraud) / COUNT(*) * 100, 4) AS rule_precision_pct
FROM v_fraud_rule_engine WHERE pts_device > 0;


--  THE DECISION MATRIX: Automated Decisioning Logic
-- Strategy: Use MFA (Step-Up) for suspicious items; reserve BLOCK for high-certainty threats.
WITH ScoredTransactions AS (
    SELECT
        isFraud,
        (pts_type + pts_velocity + pts_device + pts_deviation) AS total_risk_score
    FROM v_fraud_rule_engine
)
SELECT
    CASE
        -- BLOCK: Reserved for the 'Perfect Storm' of red flags (Score 100+)
        WHEN total_risk_score >= 100 THEN '🛑 BLOCK'
        
        -- STEP-UP: Moderate risks trigger a challenge (MFA) to prevent False Positives
        WHEN total_risk_score >= 40 THEN '⚠️ STEP-UP (OTP/MFA)'
        
        -- AUTO-APPROVE: Low-risk items pass through for best UX
        ELSE '✅ AUTO-APPROVE'
    END AS automated_decision,
    
    COUNT(*) AS total_volume,
    SUM(isFraud) AS fraud_caught,
    SUM(CASE WHEN isFraud = 0 THEN 1 ELSE 0 END) AS legitimate_users_flagged,
    ROUND(SUM(isFraud) / COUNT(*) * 100, 3) AS confidence_score_pct
FROM ScoredTransactions
GROUP BY 1
ORDER BY 
    CASE 
        WHEN automated_decision = '✅ AUTO-APPROVE' THEN 1 
        WHEN automated_decision = '⚠️ STEP-UP (OTP/MFA)' THEN 2 
        ELSE 3 
    END;
