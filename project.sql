-- create database project;

use project;

select * from annex1;

select * from annex4;

#BEGINNER — SELECT, WHERE, ORDER BY, LIMIT

# 1. How many items are present in the dataset?

SELECT COUNT(*) AS total_items
FROM annex1;

#2 How many different categories are there

SELECT COUNT(DISTINCT `Category Name`) AS total_categories
FROM annex1;

#3. How many items belong to each category?

SELECT 
    `Category Name`,
    COUNT(*) AS item_count
FROM annex1
GROUP BY `Category Name`
ORDER BY item_count DESC;


#4. List all items belonging to the Cabbage category.

SELECT 
    `Item Code`,
    `Item Name`
FROM annex1
WHERE `Category Name` = 'Cabbage';


#5. Find all items with a loss rate greater than 20%.

SELECT 
    `Item Name`,
    `Loss Rate (%)`
FROM annex4
WHERE `Loss Rate (%)` > 20
ORDER BY `Loss Rate (%)` DESC;

#6. Find the 10 items with the highest loss rate.

SELECT 
    `Item Name`,
    `Loss Rate (%)`
FROM annex4
ORDER BY `Loss Rate (%)` DESC
LIMIT 10;

ALTER TABLE annex4
CHANGE `ï»¿Item Code` `Item Code` BIGINT; 

 DESCRIBE annex4;  

#INTERMEDIATE
# 7. Display item name, category and loss rate together.

SELECT 
    a.`Item Code`,
    a.`Item Name`,
    a.`Category Name`,
    b.`Loss Rate (%)`
FROM annex1 AS a
INNER JOIN annex4 AS b
    ON a.`Item Code` = b.`Item Code`;
    
#8. What is the average loss rate of all items?

SELECT 
    ROUND(AVG(`Loss Rate (%)`), 2) AS average_loss_rate
FROM annex4;
    
#9 What is the highest loss rate?

SELECT 
    MAX(`Loss Rate (%)`) AS highest_loss_rate
FROM annex4;

#10 Which item has the highest loss rate?


SELECT 
    `Item Name`,
    `Loss Rate (%)`
FROM annex4
ORDER BY `Loss Rate (%)` DESC
LIMIT 1;

#11 What is the lowest loss rate?

SELECT 
    MIN(`Loss Rate (%)`) AS lowest_loss_rate
FROM annex4;

#12. Find the average loss rate for each category.

SELECT 
    a.`Category Name`,
    ROUND(AVG(b.`Loss Rate (%)`), 2) AS average_loss_rate
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
GROUP BY a.`Category Name`
ORDER BY average_loss_rate DESC;

#13. Which categories have an average loss rate above 10%?

SELECT 
    a.`Category Name`,
    ROUND(AVG(b.`Loss Rate (%)`), 2) AS average_loss_rate
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
GROUP BY a.`Category Name`
HAVING AVG(b.`Loss Rate (%)`) > 10
ORDER BY average_loss_rate DESC;

#14. How many items in each category have a loss rate above 10%?

SELECT 
    a.`Category Name`,
    COUNT(*) AS high_loss_items
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
WHERE b.`Loss Rate (%)` > 10
GROUP BY a.`Category Name`
ORDER BY high_loss_items DESC;

#15. Find average, minimum and maximum loss rate for each category.

SELECT 
    a.`Category Name`,
    ROUND(AVG(b.`Loss Rate (%)`), 2) AS average_loss,
    MIN(b.`Loss Rate (%)`) AS minimum_loss,
    MAX(b.`Loss Rate (%)`) AS maximum_loss
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
GROUP BY a.`Category Name`
ORDER BY average_loss DESC;

#16. How many items have a loss rate greater than 10%?

SELECT 
    COUNT(*) AS items_above_10_percent
FROM annex4
WHERE `Loss Rate (%)` > 10;

#ADVANCED
#17. Find items whose loss rate is higher than the overall average.

SELECT 
    a.`Item Name`,
    a.`Category Name`,
    b.`Loss Rate (%)`
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
WHERE b.`Loss Rate (%)` > (
    SELECT AVG(`Loss Rate (%)`)
    FROM annex4
)
ORDER BY b.`Loss Rate (%)` DESC;

#18. Rank items by loss rate within each category.

SELECT
    a.`Category Name`,
    a.`Item Name`,
    b.`Loss Rate (%)`,
    RANK() OVER (
        PARTITION BY a.`Category Name`
        ORDER BY b.`Loss Rate (%)` DESC
    ) AS loss_rank
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
ORDER BY a.`Category Name`, loss_rank;

#19. Find the highest-loss item from each category.

WITH ranked_items AS (
    SELECT
        a.`Category Name`,
        a.`Item Name`,
        b.`Loss Rate (%)`,
        RANK() OVER (
            PARTITION BY a.`Category Name`
            ORDER BY b.`Loss Rate (%)` DESC
        ) AS rnk
    FROM annex1 a
    JOIN annex4 b
        ON a.`Item Code` = b.`Item Code`
)
SELECT
    `Category Name`,
    `Item Name`,
    `Loss Rate (%)`
FROM ranked_items
WHERE rnk = 1;

#20 Find the top 3 highest-loss items in every category.

WITH ranked_items AS (
    SELECT
        a.`Category Name`,
        a.`Item Name`,
        b.`Loss Rate (%)`,
        RANK() OVER (
            PARTITION BY a.`Category Name`
            ORDER BY b.`Loss Rate (%)` DESC
        ) AS rnk
    FROM annex1 a
    JOIN annex4 b
        ON a.`Item Code` = b.`Item Code`
)
SELECT
    `Category Name`,
    `Item Name`,
    `Loss Rate (%)`,
    rnk
FROM ranked_items
WHERE rnk <= 3
ORDER BY `Category Name`, rnk;

#21. Which categories have a maximum loss rate above 20%?

SELECT
    a.`Category Name`,
    MAX(b.`Loss Rate (%)`) AS maximum_loss
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
GROUP BY a.`Category Name`
HAVING MAX(b.`Loss Rate (%)`) > 20
ORDER BY maximum_loss DESC;

#22. What percentage of items have a loss rate above 10%?

SELECT
    ROUND(
        SUM(
            CASE 
                WHEN `Loss Rate (%)` > 10 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_high_loss
FROM annex4;

#23. Categorize items according to their loss rate.

SELECT
    a.`Item Name`,
    a.`Category Name`,
    b.`Loss Rate (%)`,
    CASE
        WHEN b.`Loss Rate (%)` = 0 THEN 'No Loss'
        WHEN b.`Loss Rate (%)` <= 5 THEN 'Low Loss'
        WHEN b.`Loss Rate (%)` <= 10 THEN 'Medium Loss'
        WHEN b.`Loss Rate (%)` <= 20 THEN 'High Loss'
        ELSE 'Very High Loss'
    END AS loss_category
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
ORDER BY b.`Loss Rate (%)` DESC;

#VIEW

#24. Create a summary view

CREATE VIEW item_loss_summary AS
SELECT
    a.`Item Code`,
    a.`Item Name`,
    a.`Category Code`,
    a.`Category Name`,
    b.`Loss Rate (%)`
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`;
    
#25. Create a category-level summary view

CREATE VIEW category_loss_summary AS
SELECT
    a.`Category Name`,
    COUNT(*) AS total_items,
    ROUND(AVG(b.`Loss Rate (%)`), 2) AS average_loss,
    MIN(b.`Loss Rate (%)`) AS minimum_loss,
    MAX(b.`Loss Rate (%)`) AS maximum_loss
FROM annex1 a
JOIN annex4 b
    ON a.`Item Code` = b.`Item Code`
GROUP BY a.`Category Name`;