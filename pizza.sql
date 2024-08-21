create database pizza;

create table pizzas (
	pizza_id varchar(50),
	pizza_type_id varchar(50),
	size varchar(50),
	price float
);

CREATE TABLE orders (
    order_id int,
    date date,
    time time
);

CREATE TABLE order_details (
    order_details_id int,
    order_id int,
    pizza_id VARCHAR(500),
	quantity int
);

create table pizza_types (
	pizza_type_id varchar(100),
	name varchar(500),
	category varchar(100),
	ingredients varchar(5000)
)


--- 1. Retrieve the total number of orders placed.

select count(*) as total_orders from orders;

--- 2. Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price)::numeric, 2) AS total_revenue
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id;


--- 3. Identify the highest-priced pizza.

SELECT pizza_types.name, pizzas.price
FROM pizzas  
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

--- 4. Identify the most common pizza size ordered.

SELECT pizzas.size, count(order_details.order_details_id)
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by count(order_details.order_details_id) desc;

--- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, sum(order_details.quantity)
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by sum(order_details.quantity) desc 
limit 5;

--- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category, sum(order_details.quantity) as quantity
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by sum(order_details.quantity) desc;

--- 7. Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM time) AS hour, COUNT(order_id) as orders
FROM orders
GROUP BY EXTRACT(HOUR FROM time)
ORDER BY COUNT(order_id) desc;

--- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, count(name) from pizza_types
group by category
order by count(name) desc;

--- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(qty),0) from
(SELECT orders.date, sum(order_details.quantity) as qty
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.date) as orders_qty;
	
--- 10. Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by revenue desc 
limit 3;

--- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category, 
    ROUND(
        (SUM(order_details.quantity * pizzas.price) / 
        (SELECT SUM(order_details.quantity * pizzas.price) FROM pizzas  
         JOIN order_details ON order_details.pizza_id = pizzas.pizza_id) * 100)::numeric, 2
    ) AS revenue_percentage
FROM pizzas  
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;


--- Analyze the cumulative revenue generated over time.

SELECT 
    sales.date, 
    round(SUM(sales.revenue) OVER (ORDER BY sales.date)::numeric,2) AS cum_revenue
FROM (
    SELECT 
        orders.date, 
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizzas  
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS sales
ORDER BY sales.date;


--- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH ranked_pizzas AS (
    SELECT 
        pizza_types.name, 
        pizza_types.category, 
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rn
    FROM pizzas  
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    GROUP BY pizza_types.name, pizza_types.category
)
SELECT 
    name, 
    category, 
    revenue
FROM ranked_pizzas
WHERE rn <= 3
ORDER BY category, rn;


