/* MASTER EXPORT FOR TABLEAU
This creates a granular list of all transactions with their specific risk scores.
*/
SELECT 
    f.nameOrig AS Customer_ID,
    f.type AS Transaction_Type,
    f.amount AS Amount,
    f.isFraud AS Actual_Fraud_Status,
    d.device_type AS Device_OS,
    d.is_rooted AS Is_Rooted,
    -- Pulling the individual risk points from our View
    v.pts_type,
    v.pts_velocity,
    v.pts_device,
    v.pts_deviation,
    -- Calculating the final score and decision for every single row
    (v.pts_type + v.pts_velocity + v.pts_device + v.pts_deviation) AS total_risk_score,
    CASE 
        WHEN (v.pts_type + v.pts_velocity + v.pts_device + v.pts_deviation) >= 100 THEN ' BLOCK'
        WHEN (v.pts_type + v.pts_velocity + v.pts_device + v.pts_deviation) >= 40 THEN ' STEP-UP (OTP/MFA)'
        ELSE ' AUTO-APPROVE'
    END AS automated_decision
FROM fact_transactions f
JOIN v_fraud_rule_engine v ON f.nameOrig = v.nameOrig AND f.step = v.step
JOIN dim_devices d ON f.device_id = d.device_id;
