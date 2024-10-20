Use Projects


CREATE TABLE TBL_WMSALES
(
	Invoice_ID VARCHAR(30) NOT NULL PRIMARY KEY,
	Branch VARCHAR(5) NOT NULL,
	City VARCHAR(30) NOT NULL,
	Customer_type VARCHAR(30) NOT NULL,
	Gender VARCHAR(15) NOT NULL,
	Product_line VARCHAR(100) NOT NULL,
	Unit_price DECIMAL(10,2) NOT NULL,
	Quantity INT NOT NULL,
	VAT DECIMAL(6,4) NOT NULL,
	Total DECIMAL(10,2) NOT NULL,
	Date DATE NOT NULL,
	Time TIME NOT NULL,
	Payment_method VARCHAR(20) NOT NULL,
	cogs DECIMAL(10,2) NOT NULL,
	gross_margin_percentage DECIMAL(11,9) NOT NULL,
	gross_income DECIMAL(10,2) NOT NULL,
	Rating FLOAT NOT NULL
);

SELECT * FROM TBL_WMSALES

-- TO BULK UPLOAD DATA IN THE TABLE --

BULK INSERT TBL_WMSALES
FROM 'C:\path\to\yourfile.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- If the file has headers
);

-- TO CHECK NULL VALUES --

SELECT 
	*
FROM TBL_WMSALES
WHERE Invoice_ID IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Branch IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE City IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Customer_type IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Gender IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Product_line IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Unit_price IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Quantity IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE VAT IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Total IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Date IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Time IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Payment_method IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE cogs IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE gross_margin_percentage IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE gross_income IS NULL;

SELECT 
	*
FROM TBL_WMSALES
WHERE Rating IS NULL;

-- TO FIND TOTAL NUMBER OF RECORDS --

SELECT 
	COUNT(*) TOTAL_RECORDS
FROM TBL_WMSALES

-- **Feature Engineering:** 
-- This will help use generate some new columns from existing ones.

-- 1. Add a new column named `time_of_day` to give insight of sales in the Morning, Afternoon and Evening. 
-- This will help answer the question on which part of the day most sales are made.

ALTER TABLE TBL_WMSALES
ALTER COLUMN TIME TIME(0) NOT NULL

ALTER TABLE TBL_WMSALES
ADD TIME_OF_DAY VARCHAR(20);

SELECT * FROM TBL_WMSALES

UPDATE TBL_WMSALES
SET TIME_OF_DAY =(
		
			CASE
			    WHEN TIME BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
				WHEN TIME BETWEEN '12:00:00' AND '16:00:00' THEN 'AFTERNOON'
			ELSE 'EVENING'
			END
			);
			

-- 2. Add a new column named `day_name` that contains the extracted days of the week on which the given transaction took place 
-- (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.

ALTER TABLE TBL_WMSALES
ADD DAY_NAME VARCHAR(20);

SELECT * FROM TBL_WMSALES

UPDATE TBL_WMSALES
SET DAY_NAME = DATENAME(DW,DATE)
	
SELECT 
	DATE,
	DATENAME(DW,DATE) DAY_NAME
FROM TBL_WMSALES

-- 3. Add a new column named `month_name` that contains the extracted months of the year on which 
-- the given transaction took place (Jan, Feb, Mar).
-- Help determine which month of the year has the most sales and profit.

SELECT 
	DATE,
	DATENAME(MONTH,DATE) MONTH_NAME
FROM TBL_WMSALES;

ALTER TABLE TBL_WMSALES
ADD MONTH_NAME VARCHAR(20);

UPDATE TBL_WMSALES
SET MONTH_NAME = DATENAME(MONTH,DATE); 


SELECT * FROM TBL_WMSALES;

-- **Exploratory Data Analysis (EDA):** 
-- Exploratory data analysis is done to answer the listed questions and aims of this project.


--Business Questions To Answer

--### Generic Question

--1. How many unique cities does the data have?

SELECT
	COUNT(DISTINCT City) UNQ_CNT_CITY
FROM TBL_WMSALES


SELECT
	DISTINCT City  UNQ_CITY
FROM TBL_WMSALES

--2. In which city is each branch?

SELECT
	DISTINCT City  UNQ_CITY,
	Branch
FROM TBL_WMSALES


--### Product

--1. How many unique product lines does the data have?

SELECT 
	COUNT(DISTINCT Product_line) CNT_PL
FROM TBL_WMSALES

SELECT 
	DISTINCT Product_line UNQ_PL
FROM TBL_WMSALES


--2. What is the most common payment method?

SELECT
	DISTINCT Payment_method
FROM TBL_WMSALES

SELECT
	Payment_method,
	COUNT(*) CNT_PM
FROM TBL_WMSALES
GROUP BY Payment_method
ORDER BY COUNT(*) DESC


--3. What is the most selling product line?

SELECT
	Product_line,
	COUNT(*) CNT_PL
FROM TBL_WMSALES
GROUP BY Product_line
ORDER BY COUNT(*) DESC;


--4. What is the total revenue by month?

SELECT
	MONTH_NAME,
	SUM(TOTAL) REVENUE
FROM TBL_WMSALES
GROUP BY MONTH_NAME
ORDER BY SUM(TOTAL) DESC;

--5. What month had the largest COGS?

SELECT
	MONTH_NAME,
	SUM(cogs) COGS
FROM TBL_WMSALES
GROUP BY MONTH_NAME
ORDER BY SUM(cogs) DESC;

--6. What product line had the largest revenue?

SELECT
	Product_line,
	SUM(Total) REVENUE
FROM TBL_WMSALES
GROUP BY Product_line
ORDER BY SUM(Total) DESC;

--5. What is the city with the largest revenue?

SELECT
	City,
	SUM(Total) REVENUE
FROM TBL_WMSALES
GROUP BY City
ORDER BY SUM(Total) DESC;

--6. What product line had the largest VAT?

SELECT
	Product_line,
	SUM(VAT) REVENUE
FROM TBL_WMSALES
GROUP BY Product_line
ORDER BY SUM(VAT) DESC;

--7. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	PRODUCT_LINE,
	TOTAL,
	CASE
		WHEN TOTAL > (SELECT AVG(TOTAL) FROM TBL_WMSALES) THEN 'GOOD'
		ELSE 'BAD'
		END  sales_performance
FROM TBL_WMSALES


--8. Which branch sold more products than average product sold?

SELECT
	BRANCH, 
    SUM(quantity) QTY
FROM TBL_WMSALES
group by BRANCH
having SUM(quantity)> (SELECT AVG(quantity) FROM TBL_WMSALES);

--9. What is the most common product line by gender?

SELECT
	Product_line,
	Gender,
	COUNT(*) CNT
FROM TBL_WMSALES
GROUP BY 
	Product_line, Gender
ORDER BY COUNT(*)DESC;
	
--12. What is the average rating of each product line?

SELECT
	Product_line,
	ROUND(AVG(RATING),2) AVG_RATING
FROM TBL_WMSALES
GROUP BY Product_line
ORDER BY AVG(RATING) DESC;

--### Sales

--1. Number of sales made in each time of the day per weekday

SELECT
	TIME_OF_DAY,
	COUNT(TOTAL) CNT_SALES
FROM TBL_WMSALES
GROUP BY TIME_OF_DAY
ORDER BY 	COUNT(TOTAL) DESC;

-- DAY_NAME --'SUNDAY'

SELECT
	TIME_OF_DAY,
	COUNT(TOTAL) CNT_SALES
FROM TBL_WMSALES
WHERE DAY_NAME = 'SUNDAY'
GROUP BY TIME_OF_DAY
ORDER BY 	COUNT(TOTAL) DESC;

--2. Which of the customer types brings the most revenue?

SELECT
	Customer_type,
	SUM(TOTAL) SALES
FROM TBL_WMSALES
GROUP BY Customer_type
ORDER BY SUM(Total) DESC;

SELECT * FROM TBL_WMSALES

--3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT * FROM TBL_WMSALES

SELECT
	City,
	ROUND(AVG(VAT),2) TAX
FROM TBL_WMSALES
GROUP BY City
ORDER BY TAX DESC;


--4. Which customer type pays the most in VAT?

SELECT
	Customer_type,
	ROUND(AVG(VAT),2) TAX
FROM TBL_WMSALES
GROUP BY Customer_type
ORDER BY TAX DESC;


--### Customer

--1. How many unique customer types does the data have?

SELECT 
	COUNT(DISTINCT Customer_type) CNT
FROM TBL_WMSALES;

SELECT 
	DISTINCT Customer_type UNQ_CT
FROM TBL_WMSALES;

--2. How many unique payment methods does the data have?

SELECT 
	COUNT(DISTINCT Payment_method) CNT_PM
FROM TBL_WMSALES;

SELECT 
	DISTINCT Payment_method UNQ_PM
FROM TBL_WMSALES;

--3. What is the most common customer type?

SELECT
	CUSTOMER_TYPE,
	COUNT(CUSTOMER_TYPE) CNT_CT
FROM TBL_WMSALES
GROUP BY Customer_type
ORDER BY CNT_CT DESC;


--4. Which customer type buys the most?

SELECT
	CUSTOMER_TYPE,
	COUNT(CUSTOMER_TYPE) CNT_CT
FROM TBL_WMSALES
GROUP BY Customer_type
ORDER BY CNT_CT DESC;


--5. What is the gender of most of the customers?

SELECT
	CUSTOMER_TYPE,
	COUNT(Gender) CNT_GENTER
FROM TBL_WMSALES
GROUP BY Customer_type
ORDER BY CNT_GENTER DESC;


--6. What is the gender distribution per branch?
SELECT
	Branch,
	GENDER,
	COUNT(Quantity) CNT_QT
FROM TBL_WMSALES
GROUP BY Branch,Gender
ORDER BY CNT_QT DESC;

--7. Which time of the day do customers give most ratings?

SELECT
	Customer_type,
	TIME_OF_DAY,
	ROUND(AVG(Rating),2) RAT_AVG
FROM TBL_WMSALES
GROUP BY Customer_type,TIME_OF_DAY
ORDER BY RAT_AVG DESC;

--8. Which time of the day do customers give most ratings per branch?

SELECT
	Branch,
	TIME_OF_DAY,
	ROUND(AVG(Rating),2) RAT_AVG
FROM TBL_WMSALES
GROUP BY BRANCH,TIME_OF_DAY
ORDER BY RAT_AVG DESC;

--9. Which day fo the week has the best avg ratings?

SELECT
	DAY_NAME,
	ROUND(AVG(Rating),2) RAT_AVG
FROM TBL_WMSALES
GROUP BY DAY_NAME
ORDER BY RAT_AVG DESC;


--10. Which day of the week has the best average ratings per branch?

SELECT
	DAY_NAME,
	BRANCH,
	ROUND(AVG(Rating),2) RAT_AVG
FROM TBL_WMSALES
GROUP BY DAY_NAME,Branch
ORDER BY RAT_AVG DESC;


















