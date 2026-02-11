use Retail;
EXEC sp_rename 'analytics', 'retail_cust';


select * from retail_cust; 

--1)Identifies products with prices higher than the average price within their category.

	SELECT *
FROM (
    SELECT
        Product_ID,
        Product_Name,
        Category,
        Price,
        AVG(Price) OVER (PARTITION BY Category) AS Avg_Category_Price
    FROM retail_cust
) t
WHERE Price > Avg_Category_Price;


--2)Finding Categories with Highest Average Rating Across Products.

SELECT Category, AVG(Rating) AS Avg_Rating
FROM retail_cust
GROUP BY Category
ORDER BY Avg_Rating DESC;


--3)Find the most reviewed product in each warehouse.
SELECT *
FROM (
    SELECT 
        Product_ID,
        Product_Name,
        Warehouse,
        Reviews,
        ROW_NUMBER() OVER (
            PARTITION BY Warehouse
            ORDER BY Reviews DESC
        ) AS rn
    FROM retail_cust
) t
WHERE rn = 1;


--4)find products that have higher-than-average prices within their category, along with their discount and supplier.

 
 SELECT *
FROM (
    SELECT 
        Product_ID,
        Product_Name,
        Category,
        Price,
        Discount,
        Supplier,
        AVG(Price) OVER (PARTITION BY Category) AS Avg_Category_Price
    FROM retail_cust
) t
WHERE Price > Avg_Category_Price;


--5)Query to find the top 2 products with the highest average rating in each category


SELECT *
FROM (
    SELECT
        Product_ID,
        Product_Name,
        Category,
        AVG(Rating) AS Avg_Rating,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY AVG(Rating) DESC
        ) AS rn
    FROM retail_cust
    GROUP BY Product_ID, Product_Name, Category
) t
WHERE rn <= 2;


--6)Analysis Across All Return Policy Categories(Count, Avgstock, total stock, weighted_avg_rating, etc)*/
SELECT
    Return_Policy,
    COUNT(*) AS Product_Count,
    AVG(Stock_Quantity) AS Avg_Stock,
    SUM(Stock_Quantity) AS Total_Stock,
    
    -- weighted average rating using Reviews as weight
    SUM(Rating * Reviews) / NULLIF(SUM(Reviews), 0) AS Weighted_Avg_Rating,
    
    AVG(Rating) AS Avg_Rating,
    AVG(Price) AS Avg_Price,
    SUM(Price) AS Total_Price_Value
FROM retail_cust
GROUP BY Return_Policy
ORDER BY Return_Policy;

