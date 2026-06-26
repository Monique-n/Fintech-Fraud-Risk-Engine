# Digital Payments Fraud & Revenue Risk Intelligence Engine
<br/>

###  Real-Time Executive Risk Pulse Dashboard
![Fintech Fraud Risk Dashboard](03_Business_Intelligence_Tableau/Fintech-Fraud-Risk-Engine%20Tableau%20dashboard.png)

---

##  Project Objective
This repository houses an end-to-end, enterprise-grade risk solution designed to transition digital payment infrastructures from static manual limits into an automated, real-time risk-scoring architecture. Utilizing a structured sampling of over 100,000+ transactional telemetry records from the PaySim ecosystem, I engineered an algorithmic data preparation pipeline, constructed a normalized relational database schema, deployed a centralized SQL Risk Scoring Engine using modular Common Table Expressions (CTEs), and simulated policy thresholds. 

**The Operational Result:** Achieving a **$189M net business benefit** for the platform while maintaining a **56.3% frictionless auto-approval velocity** for verified legitimate users.

---

##  Production System Architecture
The repository is strictly decoupled into modular layers to mirror standard software engineering and data governance workflows:
*  **`01_Data_Engineering_Python/`**: High-performance ingestion, algorithmic anomaly isolation, programmatic feature extraction, and snowflake schema generation.
*  **`02_SQL_Risk_Scoring_Engine/`**: Relational data definitions, DDL index optimizations, time-series velocity calculations via window functions, and the core transaction routing view.
*  **`03_Business_Intelligence_Tableau/`**: Semantic business logic metrics extraction, dynamic policy sliders, and multi-layered executive risk performance monitoring dashboards.

---

##  Technical Implementations & Layer Breakdown

### 1. Risk Strategy & Rule Scorecard (The Governance Baseline)
Before deploying execution logic, an objective, point-based weighted scorecard matrix was established. This framework translates technical transaction telemetry into strategic risk categories, completely eliminating operational bias from the automated routing engine:

| Rule Name | Technical Telemetry Logic (The "How") | Business Hazard Mitigation | Risk Weight | Automated Operational Action |
| :--- | :--- | :--- | :--- | :--- |
| **High-Risk Flow** | `type IN ('TRANSFER', 'CASH_OUT')` | Targets capital "Outflow" channels where liquidity permanently exits the ecosystem. | **40 Pts** | Step-Up Authentication: Enforces immediate multi-factor challenge. |
| **Spending Deviation** | `amount > (avg_tx_amount * 3)` | Identifies "Out-of-Pattern" spending anomalies relative to unique user behavior benchmarks. | **40 Pts** | Hard Block / MFA: Intercepts high-certainty account takeover (ATO) attacks. |
| **Device Integrity** | `is_rooted = 1` | Detects "Tampered Hardware," the primary vector for professional fraud farms and automated scripts. | **20 Pts** | Device Challenge: Validates device-ID fingerprints before authorization. |
| **Velocity Spike** | `time_since_last_tx < 1` (Minute) | Catches rapid-fire card testing scripts or automated, high-velocity withdrawal sweeps. | **15 Pts** | Real-Time Monitor: Flags transaction velocity anomalies for audit trails. |

#### Cumulative Decision Routing Matrix:
* **`0 – 39` Points (✅ AUTO-APPROVE):** UX-First Channel. Zero friction or latency for trusted, verified actors.
* **`40 – 99` Points (⚠️ STEP-UP / MFA):** Dynamic friction. Triggers an automated SMS/OTP verification challenge to salvage transactions securely without sacrificing fee revenue.
* **`100+` Points (🛑 HARD BLOCK):** Complete loss prevention. Instant terminal drop to protect platform capital from definitive fraud signatures.

---

### 2. Data Engineering & Normalization Layer (Python)
* **Pipeline Module:** `01_Data_Engineering_Python/fraud_etl_pipeline.py`
* **Snowflake Schema Normalization:** Converted raw, highly flat database objects into an optimized transactional schema. Split the unstructured data into dedicated `dim_customers` (tracking geographical risk vectors), `dim_devices` (hardware telemetry), and a central `fact_transactions` ledger to lock in strict referential integrity constraints.
* **Behavioral Feature Engineering:** Programmed rolling user windows via Pandas and NumPy to compute real-time averages. Engineered the `is_high_deviation` rule flag by evaluating each incoming transaction amount against that user’s specific arithmetic mean history.

---

### 3. Database Infrastructure & The SQL Risk Engine
* **Engine Scripts:** Located inside `02_SQL_Risk_Scoring_Engine/`
* **Time-Series Velocity Interception:** Leveraged advanced SQL windowing functions combining `LAG()` partitioned by customer records to isolate chronological deltas down to fractional minutes between consecutive payment checkouts.
* **Central Source of Truth View:** Built `v_fraud_rule_engine`. By implementing highly readable, modular Common Table Expressions (`WITH RiskCalculations AS (...)`), the engine calculates cumulative risk points across all weights on a single pass. It saves execution overhead, maintains DRY (Don't Repeat Yourself) syntax, and dynamically appends a string-based **Audit Trail** column explaining exactly why a transaction was flagged.

---

### 4. Model Evaluation & Revenue Optimization Theory
* **The "Revenue vs. Risk" Lens:** Audited the engine's automated matrix choices against confirmed historical fraud data using confusion matrix boundaries to perfectly quantify "Customer Insult Rates" (False Positives) vs. Leakage (Recall).
* **Formulated Operational Metrics:**
  * **Revenue at Risk:** Calculated as `Fraud Loss × 1.2` to account for mandatory chargeback penalties and network operational overhead.
  * **Net Business Benefit:** Formulated as `(Fraud Loss Prevented) - (Legitimate Merchant Processing Fees Lost to False Positives)`.
* **Policy Sensitivity Discovery:** Simulating operational sliders across threshold cutoffs of 60, 70, and 80 proved that an alignment setting of **70 points** acts as the absolute financial sweet spot—capturing **85% of active system fraud** while successfully preserving an automated checkout pipeline for **98% of verified transactions**.

---

### 5. Visual Intelligence Layer (Tableau)
* **Analytics Workspace:** `03_Business_Intelligence_Tableau/`
The monitoring dashboard provides deep visibility into ecosystem security health and financial performance:
1. **Executive Risk Pulse:** High-level metric cards detailing total transactions screened, system fluidity rates, and the cumulative dollar ROI of the scoring matrix.
2. **Risk Concentration Heatmap:** A strategic matrix mapping transaction channels against value bins to expose structural blind spots in text and asset classes.
3. **Threshold Policy Dial:** An interactive parametric slider enabling leadership to visualize the inverse mathematical relationship between user friction and asset protection in real time.


##  Local Deployment & Verification Guide
To instantiate this relational schema, build the view layers, and run verification audits on a local instance:

1. **Clone the Repository:**
```bash
git clone [https://github.com/Monique-n/Fintech-Fraud-Risk-Engine.git](https://github.com/Monique-n/Fintech-Fraud-Risk-Engine.git)
cd Fintech-Fraud-Risk-Engine
