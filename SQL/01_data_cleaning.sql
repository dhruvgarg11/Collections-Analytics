-- 01_data_cleaning.sql
-- Data cleaning rules for the collections analytics pipeline

-- Remove exact duplicate borrower records
SELECT DISTINCT *
FROM borrowers;

-- Remove exact duplicate call records
SELECT DISTINCT *
FROM calls;

-- Remove exact duplicate payment records
SELECT DISTINCT *
FROM payments;

-- Remove exact duplicate WhatsApp events
SELECT DISTINCT *
FROM whatsapp_events;

-- Check missing payment references
SELECT
    payment_status,
    COUNT(*) AS records,
    SUM(CASE WHEN payment_reference IS NULL THEN 1 ELSE 0 END)
        AS missing_payment_reference
FROM payments
GROUP BY payment_status
ORDER BY payment_status;

-- Check missing agent IDs in calls
SELECT
    COUNT(*) AS total_calls,
    SUM(CASE WHEN agent_id IS NULL THEN 1 ELSE 0 END)
        AS missing_agent_id
FROM calls;

-- Check missing vendor IDs in call attempts
SELECT
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN vendor_id IS NULL THEN 1 ELSE 0 END)
        AS missing_vendor_id
FROM call_attempts;

-- Validate payment amounts
SELECT *
FROM payments
WHERE amount IS NULL
   OR amount < 0;

-- Validate payment statuses
SELECT DISTINCT payment_status
FROM payments
ORDER BY payment_status;

-- Validate account status values
SELECT DISTINCT status
FROM account_status_history
ORDER BY status;

-- Check duplicate payment IDs
SELECT
    payment_id,
    COUNT(*) AS record_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- Check duplicate account IDs
SELECT
    account_id,
    COUNT(*) AS record_count
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;