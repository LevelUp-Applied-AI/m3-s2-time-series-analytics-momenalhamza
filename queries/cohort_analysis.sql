-- Cohort Retention Analysis (30 / 60 / 90 days)

WITH first_orders AS (
    SELECT
        customer_id,
        order_date AS first_order_date,
        DATE_TRUNC('month', order_date) AS cohort_month
    FROM (
        SELECT
            customer_id,
            order_date,
            ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY order_date
            ) AS rn
        FROM orders
    ) t
    WHERE rn = 1
),

repeat_flags AS (
    SELECT
        f.customer_id,
        f.cohort_month,

        CASE WHEN EXISTS (
            SELECT 1 FROM orders o
            WHERE o.customer_id = f.customer_id
              AND o.order_date > f.first_order_date
              AND o.order_date <= f.first_order_date + INTERVAL '30 days'
        ) THEN 1 ELSE 0 END AS retained_30d,

        CASE WHEN EXISTS (
            SELECT 1 FROM orders o
            WHERE o.customer_id = f.customer_id
              AND o.order_date > f.first_order_date
              AND o.order_date <= f.first_order_date + INTERVAL '60 days'
        ) THEN 1 ELSE 0 END AS retained_60d,

        CASE WHEN EXISTS (
            SELECT 1 FROM orders o
            WHERE o.customer_id = f.customer_id
              AND o.order_date > f.first_order_date
              AND o.order_date <= f.first_order_date + INTERVAL '90 days'
        ) THEN 1 ELSE 0 END AS retained_90d

    FROM first_orders f
)

SELECT
    cohort_month,
    COUNT(*) AS cohort_size,
    ROUND(100.0 * SUM(retained_30d) / COUNT(*), 2) AS retention_30d,
    ROUND(100.0 * SUM(retained_60d) / COUNT(*), 2) AS retention_60d,
    ROUND(100.0 * SUM(retained_90d) / COUNT(*), 2) AS retention_90d
FROM repeat_flags
GROUP BY cohort_month
ORDER BY cohort_month;