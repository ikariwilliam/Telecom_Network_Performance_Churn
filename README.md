# Telecom Network Performance & Customer Churn Analysis (Lagos)

## Project Overview

Customer churn is one of the most significant challenges faced by telecommunications companies. Losing existing subscribers not only reduces recurring revenue but also increases customer acquisition costs and negatively impacts long-term profitability.

This project simulates a real-world telecom analytics environment for a fictional Lagos-based telecommunications provider. Using PostgreSQL and Power BI, it investigates how network performance, customer behavior, and customer experience contribute to subscriber churn.

The project combines multiple operational datasets—including subscriber information, network infrastructure, usage behavior, support interactions, and retention campaigns—to identify the key factors influencing customer retention and provide data-driven business recommendations.

---

# Business Problem

The telecom operator has observed increasing subscriber churn across several areas of Lagos but lacks clear visibility into the underlying causes.

Management wants to answer questions such as:

* Are customers leaving because of poor network performance?
* Can declining customer usage predict churn before it happens?
* Which regions require network investment?
* Are retention campaigns actually reducing churn?
* Which customer segments generate the highest business value?
* What operational improvements should be prioritized to improve customer retention?

The objective of this project is to answer these questions using SQL analytics and interactive Power BI dashboards.

---

# Project Objectives

The project aims to:

* Analyze subscriber churn across different customer segments.
* Evaluate the relationship between network quality and customer retention.
* Identify high-risk regions requiring network improvements.
* Measure customer value using recharge behaviour and Average Revenue Per User (ARPU).
* Evaluate customer support performance and retention campaigns.
* Produce actionable business recommendations backed by data.

---

# Business Questions

The project answers the following business questions:

## Customer Churn
* Does declining customer usage predict churn?
* Which customer segments experience the highest churn?
* Which Lagos regions have the highest churn rates?

## Network Performance
* Do subscribers in poor-network regions churn more?
* Which Lagos regions have both poor network performance and high churn?
* Which network KPIs are most strongly associated with churn?
* Which cell towers consistently underperform?
* Do network incidents increase churn?

## Revenue & Customer Value
* Does recharge behaviour change before customers churn?
* Which customer segments generate the highest Average Revenue Per User (ARPU)?

## Customer Experience
* Do customer support issues contribute to churn?
* Did retention campaigns successfully reduce churn?

---

# Project Workflow

The project follows a complete analytics workflow from business understanding through reporting.

## 1. Business Understanding
Defined the business problem, project scope, and key stakeholder questions.

## 2. Database Design
Designed a normalized PostgreSQL database representing a realistic telecom environment, including:
* Macro Regions
* Service Zones
* Cell Towers
* Subscriber Profiles
* Subscriber Status History
* Usage Records
* Network KPIs
* Network Incidents
* Recharges
* Support Tickets
* Retention Offers
* Mobile Plans

## 3. Synthetic Data Generation
A fully synthetic dataset was generated using predefined business rules to model realistic telemetry and behaviour, including:
* Declining customer usage before churn
* Network incidents causing KPI degradation
* Poor KPIs generating support tickets
* Retention campaigns targeting at-risk subscribers
* Regional differences in customer behaviour and 5G traffic variations

The final dataset contains approximately **4 million interconnected records** across multiple relational tables.

## 4. Data Validation
Before analysis, the dataset was validated using SQL (`00_data_validation.sql` and `01_data_sanity_checks.sql`) to guarantee data integrity, foreign key consistency, and realistic distribution bounds.

## 5. SQL Analytics
Business questions are answered using PostgreSQL utilizing CTEs, Window Functions, Aggregates, CASE expressions, and multi-table joins.

## 6. Power BI Dashboard
SQL outputs are visualized in interactive executive dashboards tracking churn, network performance, and customer value.

## 7. Business Recommendations
Translates analytical findings into actionable business strategies for management.

---

# Tools & Technologies

* **PostgreSQL & SQL:** Database management, data validation, and core analytics.
* **Power BI:** Executive dashboarding and visual storytelling.
* **Git & GitHub:** Version control and remote repository management.

---

# Expected Business Outcomes

* Detect customers at risk of churning before they leave.
* Prioritize network investments in high-impact locations.
* Improve customer retention through targeted interventions and campaign tracking.
* Increase customer lifetime value and recurring revenue.

---

# Disclaimer

This project uses entirely synthetic data generated for educational and portfolio purposes. While the data models realistic telecom operations and business behaviour, it does not represent any real customers or commercial telecommunications provider.