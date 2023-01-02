--DATA PREPRATION AND UNDERSTANDING

--Q1.1. What is the total number of rows in each of the 3 tables in the database? 

    SELECT COUNT(TRANSACTION_ID) AS Number_of_rows
    FROM Transactions
    
	SELECT COUNT(CUSTOMER_ID) Number_of_rows 
	FROM Customer

	SELECT COUNT(PROD_CAT)
	 FROM prod_cat_info


-- Q2. What is the total number of transactions that have a return?

    SELECT COUNT(TOTAL_AMT) AS RETURN_TXN FROM Transactions
	WHERE total_amt LIKE '-%'


--	3. As you would have noticed, the dates provided across the datasets are not in a 
--     correct format. As first steps, pls convert the date variables into valid date formats 
--     before proceeding ahead.
     
	  SELECT CONVERT(varchar,DOB,103) AS NEW_DOB FROM Customer
	    
	  SELECT CONVERT(VARCHAR,TRAN_DATE,103) AS NEW_TXN_DATE FROM TRANSACTIONS

     
       --  4. What is the time range of the transaction data available for analysis? Show the 
--     output in number of days, months and years simultaneously in different columns. 
      
	  SELECT DATEDIFF(DAY,MIN(TRAN_DATE), MAX(TRAN_DATE)) AS NO_DAYS,
	  DATEDIFF(MONTH,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS NO_MONTH,
	  DATEDIFF(YEAR,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS NO_YEAR
	  FROM Transactions


--  5. Which product category does the sub-category “DIY” belong to? 
     
	  SELECT PROD_CAT
	  FROM prod_cat_info
	  WHERE PROD_SUBCAT LIKE 'DIY'



--     DATA ANALYSIS 

--  1. Which channel is most frequently used for transactions? 
    
	 SELECT TOP 1 Store_type,
	 COUNT(Store_type) AS COUNT_CHANNEL
	 FROM Transactions
	 GROUP BY Store_type
	 ORDER BY COUNT_CHANNEL DESC
	 
--  2. What is the count of Male and Female customers in the database?

     SELECT Gender,
	 COUNT(customer_Id) AS GENDER_COUNT 
	 FROM Customer
	 WHERE Gender IN ( 'M' , 'F')
	 GROUP BY Gender

 
--  3. From which city do we have the maximum number of customers and how many?
     
	  SELECT TOP 1 CITY_CODE,
	  COUNT(CITY_CODE) AS MAX_CUST
	  FROM Customer
	  GROUP BY city_code
	  ORDER BY MAX_CUST DESC
	  
	 --  4. How many sub-categories are there under the Books category?

     SELECT PROD_CAT,
	 COUNT(PROD_SUBCAT) AS NO_SUB_CAT
	 FROM prod_cat_info
	 WHERE prod_cat like 'Books'
	 GROUP BY PROD_CAT


--  5. What is the maximum quantity of products ever ordered?

     SELECT COUNT(QTY) AS MAX_QTY,T2.PROD_CAT 
	 FROM TRANSACTIONS AS T3
	 INNER JOIN PROD_CAT_INFO AS T2
	 ON T2.PROD_SUB_CAT_CODE = T3.PROD_SUBCAT_CODE
	 GROUP BY T2.PROD_CAT
	 ORDER BY MAX_QTY DESC
	 
	 
--  6. What is the net total revenue generated in categories Electronics and Books?
     
	
    SELECT SUM (T3.TOTAL_AMT) AS TOTAL_REVENUE
    FROM Transactions AS T3
    INNER JOIN prod_cat_info AS T2
    ON T2.prod_cat_code = T3.prod_cat_code
    AND T2.prod_sub_cat_code = T3.prod_subcat_code
    GROUP BY (prod_cat)
    HAVING T2.prod_cat IN ('Electronics' , 'Books')
 
--  7. How many customers have >10 transactions with us, excluding returns?

     SELECT COUNT(customer_id) AS NO_OF_CUST FROM
	 (
	   SELECT customer_Id , COUNT(transaction_id) AS TRANSACTIONS 
	   FROM Customer AS T1
	   INNER JOIN Transactions AS T2
	   ON T1.customer_Id = T2.cust_id
	   WHERE total_amt > 0
	   GROUP BY customer_Id
	   HAVING COUNT(transaction_id) > 10
	   )
	   X1
	  
--  8. What is the combined revenue earned from the “Electronics” & “Clothing” 
--  categories, from “Flagship stores”?

    SELECT SUM(NET_REVENUE) AS COMBINED_REVENUE FROM
	(
	SELECT SUM (TOTAL_AMT) AS NET_REVENUE, STORE_TYPE
	FROM Transactions AS T1
	INNER JOIN prod_cat_info AS T2
	ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code = T2.prod_sub_cat_code
	GROUP BY prod_cat, Store_type
	HAVING T2.prod_cat IN ( 'Electronics' , 'Clothing' ) and T1.Store_type like 'Flagship%'
	)
	X1


--  9. What is the total revenue generated from “Male” customers in “Electronics” category? 
--  Output should display total revenue by prod sub-cat. 

    SELECT PROD_SUBCAT, SUM(TOTAL_AMT) AS TOTAL_REVENUE 
	FROM Transactions AS T1 
	INNER JOIN prod_cat_info AS T2
	ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_subcat_code = T2.prod_sub_cat_code
	INNER JOIN Customer AS T3
	ON T1.cust_id = T3.customer_Id
	WHERE prod_cat = 'Electronics' and Gender = 'M'
	GROUP BY prod_subcat
	
--  10.What is percentage of sales and returns by product sub category; display only top 
--  5 sub categories in terms of sales?

	SELECT TOP 5 PROD_SUBCAT,(SUM(TOTAL_AMT)*100/(SELECT SUM(TOTAL_AMT) FROM Transactions)) AS [PERCENT_SALE],
	SUM(CASE WHEN Qty < 0 THEN Qty ELSE NULL END )*100/SUM(CASE WHEN Qty > 0 THEN Qty ELSE NULL END ) AS [PERCENT_RETURN]
    FROM Transactions AS T1
	INNER JOIN PROD_CAT_INFO AS T2
	ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	AND T1.PROD_SUBCAT_CODE = T2.PROD_SUB_CAT_CODE
	GROUP BY PROD_SUBCAT
	ORDER BY[PERCENT_SALE] DESC

--  11. For all customers aged between 25 to 35 years find what is the net total revenue generated by
--  these consumers in last 30 days of transactions from max transaction date available in the data

    SELECT CUST_ID, SUM(TOTAL_AMT) AS REVENUE
	FROM TRANSACTIONS
	WHERE CUST_ID IN
	(
	SELECT CUSTOMER_ID FROM Customer
	WHERE DATEDIFF(YEAR,DOB,GETDATE()) BETWEEN 25 AND 35
	)
	AND TRAN_DATE BETWEEN DATEADD(DAY,-30,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS))
	AND (SELECT MAX(TRAN_DATE) FROM Transactions)
	GROUP BY CUST_ID 

--  12.Which product category has seen the max value of returns in the last 3 months of transactions? 

    SELECT TOP 1 PROD_CAT, SUM(TOTAL_AMT) AS MAX_RETURN
	FROM TRANSACTIONS AS T1
	INNER JOIN PROD_CAT_INFO AS T2
	ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	AND T1.PROD_SUBCAT_CODE = T2.PROD_SUB_CAT_CODE
	WHERE TOTAL_AMT < 0
	AND TRAN_DATE BETWEEN DATEADD(MONTH,-3,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS))
	AND (SELECT MAX(TRAN_DATE) FROM TRANSACTIONS)
	GROUP BY PROD_CAT
	ORDER BY MAX_RETURN DESC


--  13.Which store-type sells the maximum products; by value of sales amount and by quantity sold?

    SELECT TOP 1 STORE_TYPE, SUM(TOTAL_AMT) AS SALES_AMOUNT, SUM(QTY) AS NET_QTY
	FROM TRANSACTIONS
	GROUP BY STORE_TYPE
	ORDER BY NET_QTY DESC
	
--  14.What are the categories for which average revenue is above the overall average. 
     
	SELECT PROD_CAT, AVG(TOTAL_AMT) AVERAGE
	FROM TRANSACTIONS AS T1
	INNER JOIN PROD_CAT_INFO AS T2
	ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	GROUP BY PROD_CAT
	HAVING AVG(TOTAL_AMT) > (SELECT AVG(TOTAL_AMT) FROM TRANSACTIONS)
	
--  15. Find the average and total revenue by each subcategory for the categories which 
--  are among top 5 categories in terms of quantity sold.
    
	SELECT PROD_CAT, PROD_SUBCAT, AVG(TOTAL_AMT) AS TOTAL_AVG, SUM(TOTAL_AMT) AS TOTAL_AMT
	FROM TRANSACTIONS AS T1
	INNER JOIN PROD_CAT_INFO AS T2
	ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	AND T1.PROD_SUBCAT_CODE = T2.PROD_SUB_CAT_CODE
	WHERE PROD_CAT IN
	(
	SELECT TOP 5 PROD_CAT FROM TRANSACTIONS AS X1
	INNER JOIN PROD_CAT_INFO AS Y1
	ON X1.PROD_CAT_CODE = Y1.PROD_CAT_CODE AND X1.PROD_SUBCAT_CODE = Y1.PROD_SUB_CAT_CODE
	GROUP BY PROD_CAT
	ORDER BY SUM(QTY) DESC
	)
	GROUP BY PROD_CAT, PROD_SUBCAT
