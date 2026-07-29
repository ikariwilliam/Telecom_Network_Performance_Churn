-- ============================================================
-- FILE: 00_data_validation.sql
-- PURPOSE: Automated Data Quality Assurance & Referential Integrity Check
-- EXPECTED RESULT: All validation checks return 0 failing rows.
-- ============================================================

SELECT '1.1 Subscribers with invalid home towers' AS validation_check, COUNT(*) AS failing_rows 
FROM subscribers AS s 
LEFT JOIN cell_towers AS t ON s.home_tower_id = t.cell_tower_id 
WHERE t.cell_tower_id IS NULL

UNION ALL
SELECT '1.2 Subscribers with invalid service zones', COUNT(*) 
FROM subscribers AS s 
LEFT JOIN service_zones AS sz ON s.service_zone_id = sz.service_zone_id 
WHERE sz.service_zone_id IS NULL

UNION ALL
SELECT '1.3 Service zones with invalid macro regions', COUNT(*) 
FROM service_zones AS sz 
LEFT JOIN macro_regions AS mr ON sz.macro_region_id = mr.macro_region_id 
WHERE mr.macro_region_id IS NULL

UNION ALL
SELECT '1.4 Usage records with invalid subscribers or towers', COUNT(*) 
FROM usage_records AS u 
LEFT JOIN subscribers AS s ON u.subscriber_id = s.subscriber_id 
LEFT JOIN cell_towers AS t ON u.cell_tower_id = t.cell_tower_id 
WHERE s.subscriber_id IS NULL OR t.cell_tower_id IS NULL

UNION ALL
SELECT '1.5 Recharges with invalid subscribers', COUNT(*) 
FROM recharges AS r 
LEFT JOIN subscribers AS s ON r.subscriber_id = s.subscriber_id 
WHERE s.subscriber_id IS NULL

UNION ALL
SELECT '3.1 Usage records logged AFTER churn date', COUNT(*) 
FROM usage_records AS u 
JOIN subscriber_status_history AS ssh ON u.subscriber_id = ssh.subscriber_id 
WHERE ssh.status = 'Churned' AND u.usage_date > ssh.status_date

UNION ALL
SELECT '3.2 Recharges logged AFTER churn date', COUNT(*) 
FROM recharges AS r 
JOIN subscriber_status_history AS ssh ON r.subscriber_id = ssh.subscriber_id 
WHERE ssh.status = 'Churned' AND r.recharge_date > ssh.status_date

UNION ALL
SELECT '4.1 Out-of-bounds KPI values', COUNT(*) 
FROM network_kpis 
WHERE dropped_call_rate_pct < 0 OR dropped_call_rate_pct > 100 
   OR packet_loss_pct < 0 OR packet_loss_pct > 100 
   OR availability_pct < 0 OR availability_pct > 100 
   OR latency_ms < 0 OR signal_strength_rsrp > 0;