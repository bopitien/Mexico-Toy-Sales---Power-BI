SELECT * FROM inventory
SELECT * FROM products
SELECT * FROM sales
SELECT * FROM stores

--round up product cost and price to 2 decimal places ---
UPDATE products
SET Product_Cost = ROUND(Product_Cost, 2),
    Product_Price = ROUND(Product_Price, 2);

	--Sales Analysis--

--1. What are the top-performing products in terms of units sold and revenue?
--Top Products by Units Sold

SELECT 
    p.Product_ID, 
    p.Product_Name, 
    SUM(s.Units) AS Total_Units_Sold
FROM Sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Units_Sold DESC;

--Top Products by Revenue

SELECT
    p.Product_ID, 
    p.Product_Name,
	SUM(s.Units) AS Total_Units_Sold,
	SUM(s.Units * p.Product_Price) as Total_Revenue
FROM Sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Units_Sold DESC;

-- Top Products by Profit

WITH metrics AS (
SELECT
    p.Product_ID as product_id, 
    p.Product_Name as product_name,
	SUM(s.Units * p.Product_Cost) AS Total_cost,
	SUM(s.Units * p.Product_Price) as Total_Revenue

FROM Sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name )

SELECT product_id, product_name, ROUND((Total_Revenue - Total_cost ),2) as profit
FROM metrics 
ORDER BY profit ASC;


---2. Which stores have the highest and lowest sales?

SELECT
    TOP 5 st.Store_Name, 
	SUM(s.Units) AS Total_Units_Sold,
	ROUND(SUM(s.Units * p.Product_Price),2) as Total_Revenue

FROM stores st
JOIN sales s ON s.Store_ID = st.Store_ID
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY st.Store_Name
ORDER BY Total_Revenue DESC

SELECT
    TOP 5 st.Store_Name, 
	SUM(s.Units) AS Total_Units_Sold,
	ROUND(SUM(s.Units * p.Product_Price),2) as Total_Revenue

FROM stores st
JOIN sales s ON s.Store_ID = st.Store_ID
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY st.Store_Name
ORDER BY Total_Revenue ASC


--3.How do sales vary by product category?

SELECT 
    p.Product_Category, 
    SUM(s.Units) AS Total_Units_Sold,
    ROUND(SUM(s.Units * p.Product_Price),2) as Total_Revenue
FROM Sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Category
ORDER BY Total_Revenue DESC;

----4.Are there any seasonal trends in toy sales? and ---How have sales evolved over time (monthly, quarterly, yearly)?


SELECT 
    FORMAT(Date, 'yyyy-MM') AS Sales_Month_Year,
    SUM(Units) AS Total_Units_Sold,
    SUM(Units * p.Product_Price) AS Total_Revenue
FROM Sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY Sales_Month_Year;

-------------------------------------------------------------------------------------

SELECT 
    CONCAT(FORMAT(Date, 'yyyy'), '-Q', DATEPART(QUARTER, Date)) AS Sales_Quarter_Year,
    SUM(Units) AS Total_Units_Sold,
    SUM(Units * p.Product_Price) AS Total_Revenue
FROM Sales s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY CONCAT(FORMAT(Date, 'yyyy'), '-Q', DATEPART(QUARTER, Date))
ORDER BY Sales_Quarter_Year;



B. Inventory Analysis
----1. Which products are most frequently out of stock?
SELECT 
    p.Product_ID, 
    p.Product_Name, 
    p.Product_Category, 
    COUNT(p.Product_ID) AS OutOfStocktimes
FROM Inventory i
JOIN Products p ON i.Product_ID = p.Product_ID
WHERE i.Stock_On_Hand = 0
GROUP BY p.Product_ID, p.Product_Name, p.Product_Category
ORDER BY OutOfStocktimes DESC;

---2. How do inventory levels differ across cities or individual stores?

---By city

SELECT 
    st.Store_City,
    SUM(i.Stock_On_Hand) AS Total_Stock_On_Hand
FROM Inventory i
JOIN Stores st ON i.Store_ID = st.Store_ID
GROUP BY st.Store_City
ORDER BY Total_Stock_On_Hand DESC;


---By Store 

SELECT 
    st.Store_ID,
    st.Store_Name,
    st.Store_City,
    SUM(i.Stock_On_Hand) AS Total_Stock_On_Hand
FROM Inventory i
JOIN Stores st ON i.Store_ID = st.Store_ID
GROUP BY st.Store_ID, st.Store_Name, st.Store_City
ORDER BY Total_Stock_On_Hand DESC;

C. Store Analysis

--1.What is the average time it takes for new stores to become profitable?




--2.Do stores in certain cities or locations perform better than others?

	SELECT 
		st.Store_City,
		SUM(sa.Units) AS Total_Units_Sold,
		ROUND(SUM(sa.Units * p.Product_Price),2) AS Total_Revenue
	FROM Sales sa
	JOIN Stores st ON sa.Store_ID = st.Store_ID
	JOIN Products p ON sa.Product_ID = p.Product_ID
	GROUP BY st.Store_City
	ORDER BY Total_Revenue DESC, Total_Units_Sold DESC;

--3. How do sales correlate with the age of the store (based on Store_Open_Date)?


WITH StoreAge AS (
    SELECT 
        Store_ID, 
		DATEDIFF(MONTH, Store_Open_Date, GETDATE()) AS AgeMonth,
        DATEDIFF(YEAR, Store_Open_Date, GETDATE()) AS AgeYear
    FROM Stores
),
AggregatedSales AS (
    SELECT 
        Store_ID, 
        SUM(Units) AS TotalUnitsSold, 
        ROUND(SUM(Units * p.Product_Price),2) AS TotalRevenue
    FROM Sales sa
    JOIN Products p ON sa.Product_ID = p.Product_ID
    GROUP BY Store_ID
)
SELECT 
    a.Store_ID,
    s.AgeMonth,
	s.AgeYear,
    a.TotalUnitsSold,
    a.TotalRevenue
FROM AggregatedSales a
JOIN StoreAge s ON a.Store_ID = s.Store_ID
ORDER BY s.AgeMonth, s.AgeYear, a.TotalRevenue DESC;


D. Product Profitability

--1. What is the profitability of each product (Product_Price - Product_Cost)?


SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Product_Category,
    p.Product_Price,
    p.Product_Cost,
    (p.Product_Price - p.Product_Cost) AS ProfitPerUnit,
    SUM(sa.Units) AS TotalUnitsSold,
    SUM(sa.Units * p.Product_Price) AS TotalRevenue,
    SUM(sa.Units * (p.Product_Price - p.Product_Cost)) AS TotalProfit
FROM Products p
JOIN Sales sa ON p.Product_ID = sa.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Product_Category, p.Product_Price, p.Product_Cost
ORDER BY TotalProfit DESC;

--2.Do higher-cost products necessarily generate more revenue or profit?


SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Product_Category,
    p.Product_Cost,
    (p.Product_Price - p.Product_Cost) AS ProfitPerUnit,
    SUM(sa.Units) AS TotalUnitsSold,
    SUM(sa.Units * p.Product_Price) AS TotalRevenue,
    SUM(sa.Units * (p.Product_Price - p.Product_Cost)) AS TotalProfit
FROM Products p
JOIN Sales sa ON p.Product_ID = sa.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Product_Category, p.Product_Cost, p.Product_Price
ORDER BY p.Product_Cost DESC;


E.Regional Analysis
--1. Are certain types of toys more popular in specific cities or regions?


SELECT 
    st.Store_City,
    p.Product_Category,
    COUNT(sa.Sale_ID) AS TotalTransactions,
    SUM(sa.Units) AS TotalUnitsSold
FROM Sales sa
JOIN Products p ON sa.Product_ID = p.Product_ID
JOIN Stores st ON sa.Store_ID = st.Store_ID
GROUP BY st.Store_City, p.Product_Category
ORDER BY st.Store_City, TotalUnitsSold DESC;



--2. Is there a difference in average transaction value across cities?

SELECT 
    st.Store_City,
    COUNT(sa.Sale_ID) AS TotalTransactions,
    ROUND(SUM(sa.Units * p.Product_Price),2) AS TotalRevenue,
    ROUND(SUM(sa.Units * p.Product_Price) / COUNT(sa.Sale_ID),2) AS AvgTransactionValue
FROM Sales sa
JOIN Products p ON sa.Product_ID = p.Product_ID
JOIN Stores st ON sa.Store_ID = st.Store_ID
GROUP BY st.Store_City
ORDER BY AvgTransactionValue DESC;



F.Customer Behavior
--1. On which days of the week do most sales occur?

SELECT 
    DATENAME(WEEKDAY, sa.Date) AS DayOfWeek,
    COUNT(sa.Sale_ID) AS TotalTransactions,
    SUM(sa.Units) AS TotalUnitsSold
FROM Sales sa
GROUP BY DATENAME(WEEKDAY, sa.Date)
ORDER BY TotalUnitsSold DESC, TotalTransactions DESC ;


--2. What is the average number of units per transaction?


SELECT 
    COUNT(Sale_ID) AS TotalTransactions,
    SUM(Units) AS TotalUnitsSold,
    (SUM(Units) * 1.0 / COUNT(Sale_ID)) AS AvgUnitsPerTransaction
FROM Sales;