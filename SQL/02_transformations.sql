-- 02_transformations.sql
-- Transformations for analytical datasets


-- 1. Create monthly payment summary

SELECT
    DATE_TRUNC('month', event_at) AS payment_month,
    COUNT(*) AS successful_payments,
    COUNT(DISTINCT account_id) AS paying_accounts,
    SUM(amount) AS recovery_amount
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY DATE_TRUNC('month', event_at)
ORDER BY payment_month;


-- 2. Create payment summary by payment method

SELECT
    payment_method,
    COUNT(*) AS successful_payments,
    COUNT(DISTINCT account_id) AS paying_accounts,
    SUM(amount) AS recovery_amount
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY payment_method
ORDER BY recovery_amount DESC;


-- 3. Create account-level payment summary

SELECT
    account_id,
    COUNT(*) AS successful_payment_count,
    SUM(amount) AS total_recovery_amount,
    MIN(event_at) AS first_payment_at,
    MAX(event_at) AS latest_payment_at
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY account_id;


-- 4. Join accounts with borrower information

SELECT
    a.account_id,
    a.borrower_id,
    a.loan_type,
    a.risk_segment,
    a.opened_at,
    b.phone,
    b.email
FROM accounts a
LEFT JOIN borrowers b
    ON a.borrower_id = b.borrower_id;


-- 5. Join targeting with campaign information

SELECT
    t.target_id,
    t.account_id,
    t.campaign_id,
    t.target_date,
    t.priority,
    t.recommended_channel,
    t.status,
    c.campaign_name
FROM daily_targeting t
LEFT JOIN campaigns c
    ON t.campaign_id = c.campaign_id;


-- 6. Add vendor information to call attempts

SELECT
    ca.attempt_id,
    ca.call_id,
    ca.vendor_id,
    v.vendor_name,
    v.timezone,
    v.schema_version
FROM call_attempts ca
LEFT JOIN vendor_telephony v
    ON ca.vendor_id = v.vendor_id;