SELECT *
FROM customers
WHERE email IS NULL
   OR TRIM(email) = ''
   OR address IS NULL
   OR TRIM(address) = ‘’;

-- This query checks for missing or empty email and address fields in the customers table to ensure data quality.

CREATE OR REPLACE VIEW public.clean_completeness AS
SELECT
    customer_id,
    name,
    COALESCE(
        NULLIF(TRIM(email), ''),
        CONCAT('unknown', customer_id, '@example.com')
    ) AS email_clean,
    COALESCE(
        NULLIF(TRIM(address), ''),
        'ADDRESS_MISSING'
    ) AS address_clean,
    CASE
        WHEN 
            (email IS NULL OR TRIM(email) = '')
            OR (address IS NULL OR TRIM(address) = '')
        THEN TRUE
        ELSE FALSE
    END AS needs_review
FROM v_completenes;

CREATE TABLE customers_clean AS
SELECT customer_id, name, email, signup_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY email
               ORDER BY signup_date DESC
           ) AS rn
    FROM customers
) t
WHERE rn = 1;


