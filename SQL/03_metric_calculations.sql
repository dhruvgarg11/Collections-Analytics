-- 03_metric_calculations.sql
-- Standard business metric calculations


-- 1. Monthly recovery amount

SELECT
    DATE_TRUNC('month', event_at) AS payment_month,
    SUM(amount) AS recovery_amount
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY DATE_TRUNC('month', event_at)
ORDER BY payment_month;


-- 2. Monthly successful payment count

SELECT
    DATE_TRUNC('month', event_at) AS payment_month,
    COUNT(*) AS successful_payments
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY DATE_TRUNC('month', event_at)
ORDER BY payment_month;


-- 3. Monthly paying accounts

SELECT
    DATE_TRUNC('month', event_at) AS payment_month,
    COUNT(DISTINCT account_id) AS paying_accounts
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY DATE_TRUNC('month', event_at)
ORDER BY payment_month;


-- 4. Average successful payment amount

SELECT
    AVG(amount) AS average_payment_amount
FROM payments
WHERE payment_status = 'SUCCESS';


-- 5. Month-on-month recovery growth

WITH monthly_recovery AS (
    SELECT
        DATE_TRUNC('month', event_at) AS payment_month,
        SUM(amount) AS recovery_amount
    FROM payments
    WHERE payment_status = 'SUCCESS'
    GROUP BY DATE_TRUNC('month', event_at)
)

SELECT
    payment_month,
    recovery_amount,
    LAG(recovery_amount) OVER (
        ORDER BY payment_month
    ) AS previous_month_recovery,
    ROUND(
        (
            recovery_amount
            - LAG(recovery_amount) OVER (
                ORDER BY payment_month
            )
        )
        / NULLIF(
            LAG(recovery_amount) OVER (
                ORDER BY payment_month
            ),
            0
        ) * 100,
        2
    ) AS mom_growth_pct
FROM monthly_recovery
ORDER BY payment_month;


-- 6. Recovery by risk segment

SELECT
    a.risk_segment,
    COUNT(DISTINCT p.account_id) AS paying_accounts,
    SUM(p.amount) AS recovery_amount
FROM payments p
JOIN accounts a
    ON p.account_id = a.account_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY a.risk_segment
ORDER BY recovery_amount DESC;s