# Telecom_Network_Performance_Churn
A data engineering and analytics project designed to investigate the operational and network-driven causes of customer churn within a telecommunications ecosystem.

### Project Progress & Engineering Log

* **Relational Database Setup:** Designed and populated a structured PostgreSQL schema across 12 telecommunications domain tables (subscribers, cell towers, service zones, macro regions, recharges, usage records, support tickets, etc.) with strict foreign key constraints.
* **Automated Data Quality Assurance (`00_data_validation.sql`):** Engineered a multi-part validation suite to guarantee zero orphan keys, enforce temporal logic (blocking post-churn activity logs), and clamp telemetry bounds on network KPIs.
* **Analytical Sanity Checks (`01_data_sanity_checks.sql`):** Implemented production-grade SQL queries to verify business logic, mapping out macro-regional churn trends, Plan ARPU distribution, tower capacity utilization, and pre-churn data usage degradation.
* **Repository Architecture:** Configured a version-controlled workspace linking local development in VS Code and pgAdmin to a live public GitHub repository.