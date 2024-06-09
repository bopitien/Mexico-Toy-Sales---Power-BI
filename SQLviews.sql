CREATE VIEW Fact_Sales_Inventory AS
SELECT 
    s.Sale_ID, 
    s.Date, 
    s.Store_ID, 
    s.Product_ID, 
    s.Units,
    i.Stock_On_Hand,
    p.Product_Price,
    p.Product_Cost,
    (s.Units * p.Product_Price) AS Revenue,
    (s.Units * p.Product_Cost) AS Cost,
    (s.Units * p.Product_Price) - (s.Units * p.Product_Cost) AS Profit
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
LEFT JOIN Inventory i ON s.Product_ID = i.Product_ID AND s.Store_ID = i.Store_ID;


CREATE VIEW Dimension_Product AS
SELECT 
    Product_ID, 
    Product_Name, 
    Product_Category
FROM Products;


CREATE VIEW Dimension_Stores AS
SELECT 
    Store_ID, 
    Store_Name, 
    Store_City, 
    Store_Location, 
    Store_Open_Date
FROM Stores;
