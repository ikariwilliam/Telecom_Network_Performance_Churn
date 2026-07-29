-- ============================================================
-- FILE: 01_data_sanity_checks.sql
-- PURPOSE: Business logic and distribution sanity checks prior to analytical modeling.
-- ============================================================


-- 1. Churn Rate by Macro Region
WITH latest_status AS (
    SELECT DISTINCT ON (subscriber_id) 
        subscriber_id, 
        status
    FROM subscriber_status_history
    ORDER BY subscriber_id, status_date DESC
)
SELECT 
    mr.macro_region_name,
    COUNT(s.subscriber_id) AS total_subscribers,
    COUNT(CASE WHEN ls.status = 'Churned' THEN 1 END) AS churned_subscribers,
    ROUND(
        COUNT(CASE WHEN ls.status = 'Churned' THEN 1 END) * 100.0 / NULLIF(COUNT(s.subscriber_id), 0), 
        2
    ) AS churn_rate_pct
FROM subscribers AS s
JOIN service_zones AS sz ON s.service_zone_id = sz.service_zone_id
JOIN macro_regions AS mr ON sz.macro_region_id = mr.macro_region_id
LEFT JOIN latest_status AS ls ON s.subscriber_id = ls.subscriber_id
GROUP BY mr.macro_region_name
ORDER BY churn_rate_pct DESC;


-- 2. Average Revenue Per User (ARPU) by Plan
SELECT 
    p.plan_name,
    COUNT(DISTINCT s.subscriber_id) AS total_subscribers,
    COALESCE(SUM(r.amount_ngn), 0) AS total_revenue,
    ROUND(
        COALESCE(SUM(r.amount_ngn), 0) / NULLIF(COUNT(DISTINCT s.subscriber_id), 0), 
        2
    ) AS arpu
FROM plans AS p
LEFT JOIN subscribers AS s ON p.plan_id = s.plan_id
LEFT JOIN recharges AS r ON s.subscriber_id = r.subscriber_id
GROUP BY p.plan_id, p.plan_name
ORDER BY arpu DESC;


-- 3. Average Dropped Call Rate by Service Zone
SELECT 
    sz.zone_name,
    COUNT(DISTINCT t.cell_tower_id) AS total_towers,
    ROUND(AVG(k.dropped_call_rate_pct), 2) AS avg_dropped_call_rate_pct,
    ROUND(AVG(k.packet_loss_pct), 2) AS avg_packet_loss_pct
FROM service_zones AS sz
JOIN cell_towers AS t ON sz.service_zone_id = t.service_zone_id
JOIN network_kpis AS k ON t.cell_tower_id = k.cell_tower_id
GROUP BY sz.zone_name
ORDER BY avg_dropped_call_rate_pct DESC;


-- 4. 4G vs 5G Cell Tower Infrastructure Mix
SELECT 
    technology,
    COUNT(*) AS total_towers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cell_towers), 2) AS pct_share
FROM cell_towers
GROUP BY technology;


-- 5. Tower Capacity Utilization (Top 10 Most Loaded Towers)
SELECT 
    t.cell_tower_id,
    t.technology,
    t.subscriber_capacity,
    COUNT(s.subscriber_id) AS assigned_subscribers,
    ROUND(
        COUNT(s.subscriber_id) * 100.0 / NULLIF(t.subscriber_capacity, 0), 
        2
    ) AS capacity_utilization_pct
FROM cell_towers AS t
LEFT JOIN subscribers AS s ON t.cell_tower_id = s.home_tower_id
GROUP BY t.cell_tower_id, t.technology, t.subscriber_capacity
ORDER BY capacity_utilization_pct DESC
LIMIT 10;


-- 6. Retention Offer Acceptance Rate
SELECT 
    offer_type,
    COUNT(*) AS total_offers_sent,
    COUNT(CASE WHEN status = 'Accepted' THEN 1 END) AS accepted_offers,
    ROUND(
        COUNT(CASE WHEN status = 'Accepted' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 
        2
    ) AS acceptance_rate_pct
FROM retention_offers
GROUP BY offer_type
ORDER BY acceptance_rate_pct DESC;


-- 7. Support Ticket Volume by Issue Type
SELECT 
    issue_type,
    COUNT(*) AS ticket_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM support_tickets), 2) AS pct_share
FROM support_tickets
GROUP BY issue_type
ORDER BY ticket_count DESC;


-- 8. Average Customer Tenure by Status
WITH latest_status AS (
    SELECT DISTINCT ON (subscriber_id) 
        subscriber_id, 
        status
    FROM subscriber_status_history
    ORDER BY subscriber_id, status_date DESC
)
SELECT 
    ls.status,
    COUNT(DISTINCT s.subscriber_id) AS total_subscribers,
    ROUND(AVG((CURRENT_DATE - s.join_date) / 30.44), 1) AS avg_tenure_months
FROM subscribers AS s
JOIN latest_status AS ls ON s.subscriber_id = ls.subscriber_id
GROUP BY ls.status;


-- 9. Churn Rate by Plan
WITH latest_status AS (
    SELECT DISTINCT ON (subscriber_id) 
        subscriber_id, 
        status
    FROM subscriber_status_history
    ORDER BY subscriber_id, status_date DESC
)
SELECT 
    p.plan_name,
    COUNT(s.subscriber_id) AS total_subscribers,
    COUNT(CASE WHEN ls.status = 'Churned' THEN 1 END) AS churned_subscribers,
    ROUND(
        COUNT(CASE WHEN ls.status = 'Churned' THEN 1 END) * 100.0 / NULLIF(COUNT(s.subscriber_id), 0), 
        2
    ) AS churn_rate_pct
FROM plans AS p
JOIN subscribers AS s ON p.plan_id = s.plan_id
LEFT JOIN latest_status AS ls ON s.subscriber_id = ls.subscriber_id
GROUP BY p.plan_id, p.plan_name
ORDER BY churn_rate_pct DESC;


-- 10. Usage Trend Before Churn
WITH churned_subscribers AS (
    SELECT DISTINCT ON (subscriber_id) 
        subscriber_id, 
        status_date AS churn_date
    FROM subscriber_status_history
    WHERE status = 'Churned'
    ORDER BY subscriber_id, status_date DESC
),
subscriber_window_usage AS (
    SELECT 
        cs.subscriber_id,
        SUM(
            CASE 
                WHEN u.usage_date BETWEEN cs.churn_date - INTERVAL '90 days' AND cs.churn_date - INTERVAL '61 days' 
                THEN u.data_mb ELSE 0 
            END
        ) AS mb_90_to_61,
        SUM(
            CASE 
                WHEN u.usage_date BETWEEN cs.churn_date - INTERVAL '60 days' AND cs.churn_date - INTERVAL '31 days' 
                THEN u.data_mb ELSE 0 
            END
        ) AS mb_60_to_31,
        SUM(
            CASE 
                WHEN u.usage_date BETWEEN cs.churn_date - INTERVAL '30 days' AND cs.churn_date - INTERVAL '8 days' 
                THEN u.data_mb ELSE 0 
            END
        ) AS mb_30_to_8,
        SUM(
            CASE 
                WHEN u.usage_date BETWEEN cs.churn_date - INTERVAL '7 days' AND cs.churn_date 
                THEN u.data_mb ELSE 0 
            END
        ) AS mb_7_to_0
    FROM churned_subscribers AS cs
    JOIN usage_records AS u ON cs.subscriber_id = u.subscriber_id
    GROUP BY cs.subscriber_id
)
SELECT 
    ROUND(AVG(mb_90_to_61), 2) AS avg_mb_90_to_61_days_prior,
    ROUND(AVG(mb_60_to_31), 2) AS avg_mb_60_to_31_days_prior,
    ROUND(AVG(mb_30_to_8), 2)  AS avg_mb_30_to_8_days_prior,
    ROUND(AVG(mb_7_to_0), 2)   AS avg_mb_7_to_0_days_prior
FROM subscriber_window_usage;