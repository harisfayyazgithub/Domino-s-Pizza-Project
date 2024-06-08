CREATE DATABASE pizzahut;
SELECT * 
FROM pizzahut.pizzas;

CREATE TABLE orders (
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY (order_id));

CREATE TABLE order_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id));

-- Retrieve the total number of orders placed?

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Sales
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name AS Name, pizzas.price AS Price
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size AS Size,
    COUNT(order_details.order_details_id) AS Order_Count
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category AS Category,
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY Hours
ORDER BY Order_count DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category AS Category, COUNT(name) AS Count_Of_Name
FROM
    pizza_types
GROUP BY category

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Quantity), 0) AS Average_Quantity_Pizza_Per_Day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    INNER JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name AS Name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

WITH TotalRevenue AS (
    SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Total_Sales
    FROM order_details
    INNER JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
)
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / TotalRevenue.Total_Sales * 100, 2) AS Percentage_Contribution
FROM pizza_types
INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
INNER JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
CROSS JOIN TotalRevenue
GROUP BY pizza_types.category, TotalRevenue.Total_Sales
ORDER BY Percentage_Contribution DESC;

-- Analyze the cumulative revenue generated over time.

-- Getting every day revenue

-- SELECT orders.order_date, sum(order_details.quantity*pizzas.price) AS Revenue
-- FROM order_details
-- INNER JOIN pizzas
-- ON order_details.pizza_id=pizzas.pizza_id
-- INNER JOIN orders
-- ON orders.order_id=order_details.order_id
-- GROUP BY orders.order_date;

-- To get a cummulative using a subquery

SELECT order_date, sum(revenue) OVER(order by order_date) AS Cum_Revenue
FROM
(SELECT orders.order_date, sum(order_details.quantity*pizzas.price) AS Revenue
FROM order_details
INNER JOIN pizzas
ON order_details.pizza_id=pizzas.pizza_id
INNER JOIN orders
ON orders.order_id=order_details.order_id
GROUP BY orders.order_date) AS Sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH PizzaRevenue AS (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS Revenue
    FROM pizza_types
    INNER JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    INNER JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
),
RankedPizzaRevenue AS (
    SELECT 
        category,
        name,
        Revenue,
        RANK() OVER (PARTITION BY category ORDER BY Revenue DESC) AS `rank`
    FROM PizzaRevenue
)
SELECT 
    category,
    name,
    Revenue,
    `rank`
FROM RankedPizzaRevenue
WHERE `rank` <= 3
ORDER BY category, `rank`;




