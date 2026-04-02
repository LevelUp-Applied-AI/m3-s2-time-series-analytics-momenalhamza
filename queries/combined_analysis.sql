-- Monthly Revenue by Segment + Growth + Running Total

WITH base AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        c.segment,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY month, c.segment
)

SELECT
    month,
    segment,
    revenue,

    LAG(revenue) OVER (
        PARTITION BY segment
        ORDER BY month
    ) AS prev_revenue,

    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (
            PARTITION BY segment
            ORDER BY month
        )) /
        LAG(revenue) OVER (
            PARTITION BY segment
            ORDER BY month
        ), 2
    ) AS growth_pct,

    SUM(revenue) OVER (
        PARTITION BY segment
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total

FROM base
ORDER BY segment, month;