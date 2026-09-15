# Vegetable_loss_analysis_sql
MySQL-based analysis of vegetable items and loss rates using SQL queries, joins, aggregations, subqueries, CTEs, window functions, and views.

 Project Overview

This project analyzes vegetable item data and their associated loss rates using **MySQL**.

The project uses two datasets:

- `annex1.csv` – contains item details and category information.
- `annex4.csv` – contains item details and loss rate percentages.

The two datasets are connected using the `Item Code` column.

The project demonstrates SQL concepts ranging from basic data retrieval to advanced analysis using JOINs, subqueries, CTEs, window functions, CASE statements, and views.

---

 Objectives

The main objectives of this project are:

- Analyze the number of items in the dataset.
- Identify different vegetable categories.
- Analyze category-wise item distribution.
- Calculate average, minimum, and maximum loss rates.
- Identify high-loss items.
- Compare loss rates across categories.
- Rank items based on loss rate.
- Create summary views for analysis.

---

 Dataset Description

 Dataset 1 – annex1.csv

| Column | Description |
|---|---|
| Item Code | Unique identifier for the item |
| Item Name | Name of the vegetable/item |
| Category Code | Identifier for the category |
| Category Name | Name of the category |

Dataset 2 – annex4.csv

| Column | Description |
|---|---|
| Item Code | Unique identifier for the item |
| Item Name | Name of the vegetable/item |
| Loss Rate (%) | Percentage loss rate of the item |

Relationship

The two datasets are joined using:

```sql
annex1.Item Code = annex4.Item Code


Tools & Technologies
MySQL
SQL
GitHub
Excel/CSV datasets

 SQL Concepts Used


Beginner

SELECT
COUNT
DISTINCT
WHERE
ORDER BY
LIMIT

Intermediate

INNER JOIN
GROUP BY
HAVING
AVG
MIN
MAX

Advanced

Subqueries
Common Table Expressions (CTEs)
RANK()
PARTITION BY
CASE statements
Views

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

Key Findings

251 total items were analyzed.
The dataset contains 6 categories.
Flower/Leaf Vegetables is the largest category with 100 items.
The overall average loss rate is 9.43%.
The highest individual loss rate is 29.25%.
High Melon (1) has the highest loss rate.
Cabbage has the highest average category loss rate at 14.14%.
83 items have a loss rate above 10%.
22 items have a 0% loss rate.
172 items have a loss rate higher than the overall average.

Result
Category	                  Highest-Loss Item	                       Loss Rate
Aquatic Tuberous Vegetables   	High Melon (1)                       	29.25%
Cabbage	                    Purple Cabbage (1)	                      25.53%
Capsicum	                     Bell Pepper (1)	                      16.33%
Edible Mushroom	     The Steak Mushrooms (Box)	                      19.80%
Flower/Leaf Vegetables               	Chuncai                       	29.03%
Solanum                   	   Dalong Eggplant                        10.94%
