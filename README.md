#  Digital Payments Fraud & Revenue Risk Intelligence System

![Dashboard Preview](Fintech-Fraud-Risk-Engine%20Tableau%20dashboard.png)

##  Executive Summary (100k Transactions Screened)
* **Net Business Benefit:** $189M  
* **Fraud Incidents Neutralized:** 141  
* **Auto-Approval Rate:** 56.3% (Optimized for Customer UX)  
* **Strategic Threshold:** Score 70 (The "Profit Equilibrium")

---

##  The Business Challenge
In Fintech, security is a double-edged sword. Stricter rules stop fraud but block legitimate revenue (False Positives). This project solves the **Security-Revenue Paradox** by using a weighted risk engine to maximize recovery while minimizing customer friction.

##  Risk Scoring Architecture
I engineered a custom scoring logic in SQL that evaluates every transaction against four high-signal risk vectors:

| Rule Name | Technical Logic | Risk Weight | Business Intent |
| :--- | :--- | :--- | :--- |
| **High-Risk Flow** | `type IN ('TRANSFER', 'CASH_OUT')` | **40 pts** | Protects permanent outflows. |
| **Velocity Spike** | `time_since_last_tx < 1 min` | **15 pts** | Detects automated script attacks. |
| **Device Integrity**| `is_rooted = 1` | **20 pts** | Identifies tampered hardware. |
| **High Deviation** | `amount > (avg * 3)` | **40 pts** | Flags account takeover behavior. |

---

##  Strategic Decision Matrix
Based on the cumulative score, the system triggers one of three automated actions:
1.  ✅ **AUTO-APPROVE (0-39):** Zero-friction experience for standard users.
2.  ⚠️ **STEP-UP MFA (40-99):** Challenges "Grey Area" transactions with OTP/SMS to protect revenue.
3.  🛑 **HARD BLOCK (100+):** Immediate intervention for "Perfect Storm" high-certainty fraud.

##  Tech Stack & Methodology
* **SQL (MySQL/PostgreSQL):** Developed complex Views, CTEs, and Window Functions to process 100,000+ rows.
* **Tableau:** Built an interactive Executive Dashboard to simulate "What-If" threshold scenarios.
* **Python:** Utilized for data cleaning, normalization, and generating behavioral features.
* **Strategic Modeling:** Net Benefit Analysis = (Fraud Prevented - False Positive Cost).

---

##  Strategic Insight
During the analysis, I identified **Score 70** as the optimal threshold. Lowering the threshold to 40 caught more fraud but spiked customer friction by 12%, whereas increasing it to 100 left the company exposed to $45M in preventable losses.

---

###  Repository Structure
* `01_database_setup.sql`: Schema design and indexing.
* `02_risk_scoring_engine.sql`: The core logic of the weighted risk engine.
* `FinTech Fraud Mitigation Architecture.twb`: Full Tableau workbook.
* `data/`: Sample datasets including Customers, Devices, and Transactions.
