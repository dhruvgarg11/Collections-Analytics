-- 04_analytical_queries.sql
-- Analytical queries for collections performance


-- 1. Monthly recovery performance

WITH monthly_recovery AS (
    SELECT
        DATE_TRUNC('month', event_at) AS payment_month,
        SUM(amount) AS recovery_amount,
        COUNT(DISTINCT account_id) AS paying_accounts
    FROM payments
    WHERE payment_status = 'SUCCESS'
    GROUP BY DATE_TRUNC('month', event_at)
)

SELECT
    payment_month,
    recovery_amount,
    paying_accounts,
    LAG(recovery_amount) OVER (
        ORDER BY payment_month
    ) AS previous_month_recovery
FROM monthly_recovery
ORDER BY payment_month;


-- 2. Recovery by loan type

SELECT
    a.loan_type,
    COUNT(DISTINCT p.account_id) AS paying_accounts,
    SUM(p.amount) AS recovery_amount
FROM payments p
JOIN accounts a
    ON p.account_id = a.account_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY a.loan_type
ORDER BY recovery_amount DESC;


-- 3. Recovery by risk segment

SELECT
    a.risk_segment,
    COUNT(DISTINCT p.account_id) AS paying_accounts,
    SUM(p.amount) AS recovery_amount
FROM payments p
JOIN accounts a
    ON p.account_id = a.account_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY a.risk_segment
ORDER BY recovery_amount DESC;


-- 4. Campaign targeting volume

SELECT
    campaign_id,
    COUNT(*) AS targeted_records,
    COUNT(DISTINCT account_id) AS targeted_accounts
FROM daily_targeting
GROUP BY campaign_id
ORDER BY targeted_accounts DESC;


-- 5. Targeting by recommended channel

SELECT
    recommended_channel,
    COUNT(*) AS targeted_records,
    COUNT(DISTINCT account_id) AS targeted_accounts
FROM daily_targeting
GROUP BY recommended_channel
ORDER BY targeted_accounts DESC;


-- 6. Call activity by agent

SELECT
    agent_id,
    COUNT(*) AS total_calls,
    COUNT(DISTINCT account_id) AS accounts_contacted
FROM calls
GROUP BY agent_id
ORDER BY total_calls DESC;


-- 7. Vendor call activity

SELECT
    ca.vendor_id,
    v.vendor_name,
    COUNT(*) AS call_attempts
FROM call_attempts ca
LEFT JOIN vendor_telephony v
    ON ca.vendor_id = v.vendor_id
GROUP BY
    ca.vendor_id,
    v.vendor_name
ORDER BY call_attempts DESC;

    
-- 8. Payment status distribution

SELECT
    payment_status,
    COUNT(*) AS payment_records,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_status
ORDER BY payment_records DESC;


-- 9. Account status distribution

SELECT
    status,
    COUNT(DISTINCT account_id) AS accounts
FROM account_status_history
GROUP BY status
ORDER BY accounts DESC;