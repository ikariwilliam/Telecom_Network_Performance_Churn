-- Q1 (v2): Does declining customer usage predict churn?
-- - Requires a subscriber to have usage records spanning the full 60-day
--   window before their anchor date (excludes recent joiners)
-- - Compares average DAILY usage (not raw sums) to stay robust to missing days

WITH churn_dates AS (
    SELECT
        subscriber_id,
        MAX(status_date) AS churn_date
    FROM subscriber_status_history
    WHERE status = 'Churned'
    GROUP BY subscriber_id
),

anchors AS (
    SELECT
        s.subscriber_id,
        (cd.subscriber_id IS NOT NULL) AS is_churned,
        COALESCE(cd.churn_date, (SELECT MAX(usage_date) FROM usage_records)) AS anchor_date
    FROM subscribers s
    LEFT JOIN churn_dates cd ON cd.subscriber_id = s.subscriber_id
),

usage_windows AS (
    SELECT
        a.subscriber_id,
        a.is_churned,
        MIN(u.usage_date) AS earliest_usage,
        SUM(CASE WHEN u.usage_date > a.anchor_date - INTERVAL '30 days'
                       AND u.usage_date <= a.anchor_date
                  THEN u.voice_minutes ELSE 0 END) AS recent_voice_sum,
        COUNT(DISTINCT CASE WHEN u.usage_date > a.anchor_date - INTERVAL '30 days'
                                  AND u.usage_date <= a.anchor_date
                             THEN u.usage_date END) AS recent_days,
        SUM(CASE WHEN u.usage_date > a.anchor_date - INTERVAL '60 days'
                       AND u.usage_date <= a.anchor_date - INTERVAL '30 days'
                  THEN u.voice_minutes ELSE 0 END) AS prior_voice_sum,
        COUNT(DISTINCT CASE WHEN u.usage_date > a.anchor_date - INTERVAL '60 days'
                                  AND u.usage_date <= a.anchor_date - INTERVAL '30 days'
                             THEN u.usage_date END) AS prior_days,
        SUM(CASE WHEN u.usage_date > a.anchor_date - INTERVAL '30 days'
                       AND u.usage_date <= a.anchor_date
                  THEN u.sms_count ELSE 0 END) AS recent_sms_sum,
        SUM(CASE WHEN u.usage_date > a.anchor_date - INTERVAL '60 days'
                       AND u.usage_date <= a.anchor_date - INTERVAL '30 days'
                  THEN u.sms_count ELSE 0 END) AS prior_sms_sum,
        SUM(CASE WHEN u.usage_date > a.anchor_date - INTERVAL '30 days'
                       AND u.usage_date <= a.anchor_date
                  THEN u.data_mb ELSE 0 END) AS recent_data_sum,
        SUM(CASE WHEN u.usage_date > a.anchor_date - INTERVAL '60 days'
                       AND u.usage_date <= a.anchor_date - INTERVAL '30 days'
                  THEN u.data_mb ELSE 0 END) AS prior_data_sum
    FROM anchors a
    JOIN usage_records u ON u.subscriber_id = a.subscriber_id
    GROUP BY a.subscriber_id, a.is_churned, a.anchor_date
    HAVING MIN(u.usage_date) <= (MAX(a.anchor_date) - INTERVAL '59 days')
       -- keeps the anchor_date reference in scope per-group
),

daily_averages AS (
    SELECT
        subscriber_id,
        is_churned,
        recent_voice_sum / NULLIF(recent_days, 0) AS recent_voice_daily,
        prior_voice_sum / NULLIF(prior_days, 0) AS prior_voice_daily,
        recent_sms_sum / NULLIF(recent_days, 0) AS recent_sms_daily,
        prior_sms_sum / NULLIF(prior_days, 0) AS prior_sms_daily,
        recent_data_sum / NULLIF(recent_days, 0) AS recent_data_daily,
        prior_data_sum / NULLIF(prior_days, 0) AS prior_data_daily
    FROM usage_windows
)

SELECT
    is_churned,
    COUNT(*) AS subscriber_count,
    ROUND(AVG(prior_voice_daily)::numeric, 2) AS avg_prior_voice_daily,
    ROUND(AVG(recent_voice_daily)::numeric, 2) AS avg_recent_voice_daily,
    ROUND((100.0 * (AVG(recent_voice_daily) - AVG(prior_voice_daily)) / NULLIF(AVG(prior_voice_daily), 0))::numeric, 1) AS voice_pct_change,
    ROUND(AVG(prior_sms_daily)::numeric, 2) AS avg_prior_sms_daily,
    ROUND(AVG(recent_sms_daily)::numeric, 2) AS avg_recent_sms_daily,
    ROUND((100.0 * (AVG(recent_sms_daily) - AVG(prior_sms_daily)) / NULLIF(AVG(prior_sms_daily), 0))::numeric, 1) AS sms_pct_change,
    ROUND(AVG(prior_data_daily)::numeric, 2) AS avg_prior_data_daily,
    ROUND(AVG(recent_data_daily)::numeric, 2) AS avg_recent_data_daily,
    ROUND((100.0 * (AVG(recent_data_daily) - AVG(prior_data_daily)) / NULLIF(AVG(prior_data_daily), 0))::numeric, 1) AS data_pct_change
FROM daily_averages
GROUP BY is_churned
ORDER BY is_churned;

-- Q2a: Churn rate by plan and gender
WITH churn_flags AS (
    SELECT DISTINCT subscriber_id
    FROM subscriber_status_history
    WHERE status = 'Churned'
)

SELECT
    p.plan_name,
    p.plan_type,
    s.gender,
    COUNT(*) AS total_subscribers,
    COUNT(cf.subscriber_id) AS churned_subscribers,
    ROUND(100.0 * COUNT(cf.subscriber_id) / COUNT(*), 2) AS churn_rate_pct
FROM subscribers s
JOIN plans p ON p.plan_id = s.plan_id
LEFT JOIN churn_flags cf ON cf.subscriber_id = s.subscriber_id
GROUP BY p.plan_name, p.plan_type, s.gender
ORDER BY churn_rate_pct DESC;
-- Q2b: Churn rate by age band, macro region, service zone, and tenure
WITH churn_info AS (
    SELECT
        subscriber_id,
        MAX(status_date) AS churn_date
    FROM subscriber_status_history
    WHERE status = 'Churned'
    GROUP BY subscriber_id
),

subscriber_enriched AS (
    SELECT
        s.subscriber_id,
        s.age,
        s.join_date,
        mr.macro_region_name,
        sz.zone_name,
        (ci.subscriber_id IS NOT NULL) AS is_churned,
        COALESCE(ci.churn_date, DATE '2025-12-31') AS end_date,
        CASE
            WHEN s.age BETWEEN 18 AND 30 THEN '18-30'
            WHEN s.age BETWEEN 31 AND 43 THEN '31-43'
            WHEN s.age BETWEEN 44 AND 56 THEN '44-56'
            WHEN s.age BETWEEN 57 AND 70 THEN '57-70'
            ELSE 'Unknown'
        END AS age_band
    FROM subscribers s
    JOIN service_zones sz ON sz.service_zone_id = s.service_zone_id
    JOIN macro_regions mr ON mr.macro_region_id = sz.macro_region_id
    LEFT JOIN churn_info ci ON ci.subscriber_id = s.subscriber_id
),

with_tenure AS (
    SELECT
        *,
        (end_date - join_date) AS tenure_days,
        CASE
            WHEN (end_date - join_date) < 90 THEN '0-3 months'
            WHEN (end_date - join_date) < 180 THEN '3-6 months'
            WHEN (end_date - join_date) < 365 THEN '6-12 months'
            WHEN (end_date - join_date) < 730 THEN '1-2 years'
            ELSE '2+ years'
        END AS tenure_band
    FROM subscriber_enriched
)

SELECT 'Age Band' AS dimension, age_band AS segment,
       COUNT(*) AS total_subscribers,
       COUNT(*) FILTER (WHERE is_churned) AS churned_subscribers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / COUNT(*), 2) AS churn_rate_pct
FROM with_tenure
GROUP BY age_band

UNION ALL

SELECT 'Macro Region', macro_region_name,
       COUNT(*), COUNT(*) FILTER (WHERE is_churned),
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / COUNT(*), 2)
FROM with_tenure
GROUP BY macro_region_name

UNION ALL

SELECT 'Service Zone', zone_name,
       COUNT(*), COUNT(*) FILTER (WHERE is_churned),
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / COUNT(*), 2)
FROM with_tenure
GROUP BY zone_name

UNION ALL

SELECT 'Tenure', tenure_band,
       COUNT(*), COUNT(*) FILTER (WHERE is_churned),
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / COUNT(*), 2)
FROM with_tenure
GROUP BY tenure_band

ORDER BY dimension, churn_rate_pct DESC;

-- Q3: Which Lagos regions and service zones have the highest churn rates?
-- Identifies geographic hotspots by combining churn RATE (risk) with
-- churn VOLUME SHARE (concentration) at both macro region and service zone level.

WITH churn_info AS (
    SELECT DISTINCT subscriber_id
    FROM subscriber_status_history
    WHERE status = 'Churned'
),

subscriber_geo AS (
    SELECT
        s.subscriber_id,
        mr.macro_region_id,
        mr.macro_region_name,
        sz.service_zone_id,
        sz.zone_name,
        (ci.subscriber_id IS NOT NULL) AS is_churned
    FROM subscribers s
    JOIN service_zones sz ON sz.service_zone_id = s.service_zone_id
    JOIN macro_regions mr ON mr.macro_region_id = sz.macro_region_id
    LEFT JOIN churn_info ci ON ci.subscriber_id = s.subscriber_id
),

total_churn AS (
    SELECT COUNT(*) AS total_churned FROM subscriber_geo WHERE is_churned
),

region_level AS (
    SELECT
        macro_region_name,
        COUNT(*) AS total_subscribers,
        COUNT(*) FILTER (WHERE is_churned) AS churned_subscribers,
        ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / COUNT(*), 2) AS churn_rate_pct,
        ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / (SELECT total_churned FROM total_churn), 2) AS pct_of_all_churn
    FROM subscriber_geo
    GROUP BY macro_region_name
),

zone_level AS (
    SELECT
        macro_region_name,
        zone_name,
        COUNT(*) AS total_subscribers,
        COUNT(*) FILTER (WHERE is_churned) AS churned_subscribers,
        ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / COUNT(*), 2) AS churn_rate_pct,
        ROUND(100.0 * COUNT(*) FILTER (WHERE is_churned) / (SELECT total_churned FROM total_churn), 2) AS pct_of_all_churn,
        RANK() OVER (PARTITION BY macro_region_name ORDER BY COUNT(*) FILTER (WHERE is_churned) * 1.0 / COUNT(*) DESC) AS rank_within_region
    FROM subscriber_geo
    GROUP BY macro_region_name, zone_name
)

SELECT
    'Region Summary' AS level,
    macro_region_name AS region,
    NULL AS zone,
    NULL AS rank_within_region,
    total_subscribers,
    churned_subscribers,
    churn_rate_pct,
    pct_of_all_churn
FROM region_level

UNION ALL

SELECT
    'Zone Detail',
    macro_region_name,
    zone_name,
    rank_within_region,
    total_subscribers,
    churned_subscribers,
    churn_rate_pct,
    pct_of_all_churn
FROM zone_level

ORDER BY level DESC, pct_of_all_churn DESC;

-- Q4a: Time spent "At Risk" before churning
-- Measures days between a subscriber's first "At Risk" status and their
-- eventual "Churned" status (their full risk-to-churn window).

WITH first_at_risk AS (
    SELECT
        subscriber_id,
        MIN(status_date) AS at_risk_date
    FROM subscriber_status_history
    WHERE status = 'At Risk'
    GROUP BY subscriber_id
),

churn_date AS (
    SELECT
        subscriber_id,
        MAX(status_date) AS churned_date
    FROM subscriber_status_history
    WHERE status = 'Churned'
    GROUP BY subscriber_id
)

SELECT
    COUNT(*) AS churned_subscribers_with_at_risk_history,
    ROUND(AVG(cd.churned_date - fa.at_risk_date), 1) AS avg_days_at_risk_to_churn,
    MIN(cd.churned_date - fa.at_risk_date) AS min_days,
    MAX(cd.churned_date - fa.at_risk_date) AS max_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (cd.churned_date - fa.at_risk_date)) AS median_days
FROM first_at_risk fa
JOIN churn_date cd ON cd.subscriber_id = fa.subscriber_id;
-- Q4b: Outcome after receiving a retention offer
-- For every subscriber who was ever offered retention, checks what their
-- LATEST status ended up being (Recovered, Churned, or still At Risk/Active).

WITH offered AS (
    SELECT DISTINCT subscriber_id
    FROM subscriber_status_history
    WHERE status = 'Retention Offered'
),

latest_status AS (
    SELECT DISTINCT ON (subscriber_id)
        subscriber_id,
        status AS final_status
    FROM subscriber_status_history
    ORDER BY subscriber_id, status_date DESC
)

SELECT
    ls.final_status,
    COUNT(*) AS subscriber_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM offered), 2) AS pct_of_offered
FROM offered o
JOIN latest_status ls ON ls.subscriber_id = o.subscriber_id
GROUP BY ls.final_status
ORDER BY subscriber_count DESC;
-- Q4c: Most common status sequences (lifecycle paths)
-- Builds each subscriber's full ordered status history into a single string
-- (e.g. "Active -> At Risk -> Retention Offered -> Churned") and ranks
-- the most frequent paths, split between churned and non-churned outcomes.

WITH ordered_path AS (
    SELECT
        subscriber_id,
        STRING_AGG(status, ' -> ' ORDER BY status_date) AS lifecycle_path,
        BOOL_OR(status = 'Churned') AS is_churned
    FROM subscriber_status_history
    GROUP BY subscriber_id
)

SELECT
    is_churned,
    lifecycle_path,
    COUNT(*) AS subscriber_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY is_churned), 2) AS pct_within_outcome
FROM ordered_path
GROUP BY is_churned, lifecycle_path
ORDER BY is_churned DESC, subscriber_count DESC;