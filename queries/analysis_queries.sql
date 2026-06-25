SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
       ROUND(SUM(payment_value), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset op ON o.order_id = op.order_id
GROUP BY month
ORDER BY month;


SELECT product_category_name, COUNT(*) AS total_orders
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY product_category_name
ORDER BY total_orders DESC
LIMIT 10;



SELECT customer_state,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date,
       order_purchase_timestamp)), 1) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
ORDER BY avg_delivery_days;



SELECT customer_type, COUNT(*) AS total
FROM (
  SELECT customer_unique_id,
         CASE WHEN COUNT(order_id) > 1 THEN 'Repeat Customer'
              ELSE 'One-time Customer' END AS customer_type
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  GROUP BY customer_unique_id
) 
GROUP BY customer_type;



SELECT payment_type,
       ROUND(SUM(payment_value), 2) AS total_revenue,
       COUNT(*) AS total_transactions
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_revenue DESC;


WITH monthly AS (
  SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
         ROUND(SUM(payment_value), 2) AS revenue
  FROM olist_orders_dataset o
  JOIN olist_order_payments_dataset op ON o.order_id = op.order_id
  GROUP BY month
)
SELECT month, revenue,
       ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) /
       LAG(revenue) OVER (ORDER BY month)) * 100, 2) AS growth_pct
FROM monthly;