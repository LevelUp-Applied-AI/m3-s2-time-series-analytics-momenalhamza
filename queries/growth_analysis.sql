-- Monthly Revenue + Growth

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)

SELECT
    month,
    revenue,
    orders_count,

    LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month), 2
    ) AS revenue_growth_pct,

    LAG(orders_count) OVER (ORDER BY month) AS prev_orders,
    ROUND(
        100.0 * (orders_count - LAG(orders_count) OVER (ORDER BY month))
        / LAG(orders_count) OVER (ORDER BY month), 2
    ) AS orders_growth_pct

FROM monthly_revenue
ORDER BY month;