-- Daily Revenue + Moving Averages

WITH daily_revenue AS (
    SELECT
        DATE_TRUNC('day', o.order_date) AS day,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY day
)

SELECT
    day,
    revenue,
    orders_count,

    -- 7-day moving average
    AVG(revenue) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS revenue_7d_avg,

    -- 30-day moving average
    AVG(revenue) OVER (
        ORDER BY day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS revenue_30d_avg,

    AVG(orders_count) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS orders_7d_avg

FROM daily_revenue
ORDER BY day;