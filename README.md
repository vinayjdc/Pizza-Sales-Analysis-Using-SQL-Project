# Pizza-Sales-Analysis-Using-SQL-Project

## Project Overview

**Project Title**: Pizza Sales Analysis  

This SQL project analyzes a pizza sales dataset to gain insights into various aspects of the business. The dataset includes information about orders, pizza types, prices, and order timings. By using SQL queries, the project aims to retrieve meaningful data that can help understand customer preferences, optimize the menu, and improve overall business strategies.

## Objectives

This pizza sales project aims to analyze the sales data to extract actionable insights that can inform business decisions. By utilizing SQL, the project aims to:

1. **Understand Sales Performance**: Calculate total orders, and revenue, and identify the best-performing pizzas in terms of sales volume and revenue.
2. **Customer Preferences**: Identify the most popular pizza sizes and types to understand customer preferences and demand patterns.
3. **Optimize Inventory and Menu**: Analyze the distribution of orders by time and category to optimize inventory management and tailor the menu to meet customer demand effectively.
4. **Revenue Analysis**: Assess the contribution of different pizza types to total revenue and evaluate revenue trends over time to support strategic planning and forecasting.

## Project Structure

```sql
--- SQL Pizza Analysis ---
Create database pizza;

--- Create Table ---
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

```

### Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Retrieve the total number of orders placed**:
```sql
select count(*) as total_orders from orders;
```

2. **Calculate the total revenue generated from pizza sales**:
```sql
SELECT ROUND(SUM(order_details.quantity * pizzas.price)::numeric, 2) AS total_revenue
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id;
```

3. **Identify the highest-priced pizza.**:
```sql
SELECT pizza_types.name, pizzas.price
FROM pizzas  
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;
```

4. **Identify the most common pizza size ordered.**:
```sql
SELECT pizzas.size, count(order_details.order_details_id)
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by count(order_details.order_details_id) desc;
```

5. **List the top 5 most ordered pizza types along with their quantities.**:
```sql
SELECT pizza_types.name, sum(order_details.quantity)
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by sum(order_details.quantity) desc 
limit 5;
```

6. **Join the necessary tables to find the total quantity of each pizza category ordered.**:
```sql
SELECT pizza_types.category, sum(order_details.quantity) as quantity
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by sum(order_details.quantity) desc;
```

7. **Determine the distribution of orders by hour of the day.**:
```sql
SELECT EXTRACT(HOUR FROM time) AS hour, COUNT(order_id) as orders
FROM orders
GROUP BY EXTRACT(HOUR FROM time)
ORDER BY COUNT(order_id) desc;
```

8. **Join relevant tables to find the category-wise distribution of pizzas. **:
```sql
SELECT category, count(name) from pizza_types
group by category
order by count(name) desc;
```

9. **Group the orders by date and calculate the average number of pizzas ordered per day.**:
```sql
select round(avg(qty),0) from
(SELECT orders.date, sum(order_details.quantity) as qty
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.date) as orders_qty;
```

10. **Determine the top 3 most ordered pizza types based on revenue.**:
```sql
select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
FROM pizzas  
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by revenue desc 
limit 3;
```

11. **Calculate the percentage contribution of each pizza type to total revenue.**:
```sql
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
```

12. **Analyze the cumulative revenue generated over time.**:
```sql
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
```

13. **Determine the top 3 most ordered pizza types based on revenue for each pizza category.**:
```sql
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
```

## Suggestion and solution

1. **Promote Top-Selling Pizzas**: Focus on marketing and promotions for the top 3 revenue-generating pizza types in each category.
2. **Use Revenue Trends**: Analyze revenue trends over time to optimize inventory, staffing, and marketing efforts during peak and off-peak times.
3. **Optimize Pizza Sizes**: Streamline the menu by focusing on the most popular pizza sizes, potentially reducing costs and enhancing customer satisfaction.
4. **Enhance Operational Efficiency**: Align staffing and preparation with peak order times to reduce wait times and improve service.
5. **Refine Product Mix**: Focus on high-margin, high-demand pizzas while phasing out less popular options.
6. **Maximize Customer Engagement**: Create loyalty programs or promotions based on the top 5 most ordered pizzas to encourage repeat purchases.
7. **Strategic Pricing**: Introduce premium versions of popular pizzas and assess pricing strategies to maximize revenue.
8. **Data-Driven Decision-Making**: Regularly update data analysis to monitor sales performance and customer preferences for informed decision-making.

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
