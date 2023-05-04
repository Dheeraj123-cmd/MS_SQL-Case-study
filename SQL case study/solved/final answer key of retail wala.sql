----------- DATA PREPRATION AND UNDERSTANDING--------
create database Retail_data_analyis;
use Retail_data_analyis;

--Question1--

select count(*) as [Total rows in customer table] from  dbo.customer ;
select count (*) as [Total no. of rows in prod_cat_info table] from dbo.prod_cat_info;
select count (*) as [Total no. of rows in transactions table] from dbo.Transactions;

--Question2--

select sum(case when Qty<0 then 1 else 0 end) as [Total no. of return transactions] from dbo.Transactions;

--Question3--

select year(convert(date,tran_date,102)) as [corrected tran_date],tran_date from Transactions;
select convert(date,DOB,102) as [Corrected DOB],DOB from Customer;

--(Convert with Update) command(not used in this database but can be used in future requirments)--

begin tran
update Transactions
set tran_date = CONVERT(date,tran_date,102)
rollback;

--Question4--


select min(tran_date) as [Starting transaction date], max(tran_date) as [End transaction date],
DATEDIFF(DAY, MIN(CONVERT(Date, TRAN_DaTE, 102)), MAX(CONVERT(DATE, TRAN_DaTE, 102))) as [Difference in days], 
DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DaTE, 102)), MAX(CONVERT(DATE, TRAN_DaTE, 102))) as [Difference in month],  
DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DaTE, 102)), MAX(CONVERT(DATE, TRAN_DaTE, 102))) as [Difference in years] 
FROM Transactions

--Question5--

select * from prod_cat_info
where prod_subcat = 'DIY';  


-----------------DATA ANALYSIS--------------------


--Question1--

SELECT TOP 1 Store_type ,COUNT(Store_type) AS [COUNT OF CHANNELS] FROM TRANSACTIONS
GROUP BY STORE_TYPE
ORDER BY COUNT(Store_type) DESC;

--Question2--

SELECT	gender,count(Gender) AS [Count of gender] from Customer
where Gender = 'M' OR Gender = 'F'
group by Gender
ORDER BY COUNT(Gender) DESC;


--Question3--

SELECT TOP 1 CITY_CODE,COUNT(CITY_CODE) AS [COUNT OF MAXIMUM NO. OF CUSTOMER] FROM Customer
GROUP BY city_code
ORDER BY COUNT(CITY_CODE) DESC;

--Question4--

SELECT Prod_cat,count(prod_subcat) as [Count of sub categories] FROM prod_cat_info
WHERE prod_cat = 'Books'
group by prod_cat;

--Question5--

SELECT TOP 1 T.Prod_cat_code,P.Prod_cat,MAX(T.Qty) [Max quantity of product ordered Ever] FROM Transactions T
LEFT JOIN prod_cat_info P
ON T.prod_cat_code = P.prod_cat_code 
GROUP BY T.PROD_CAT_CODE ,P.prod_cat,T.Qty

--Question6--(why answer is diffrent when using 'and' wala part 'and' without and wala part )

select P.Prod_cat,P.Prod_cat_code,SUM(CAST(T.total_amt AS float)) AS [Net total revenue] from prod_cat_info P
INNER JOIN Transactions T
ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
WHERE P.prod_cat in('Electronics','Books')
GROUP BY P.prod_cat_code,P.prod_cat;

--Question7--

select cust_id,count(cust_id) as [Count of customer id] from Transactions
where Qty>'0'
group by cust_id
having count(cust_id)>10

--Question8--

select P.Prod_cat_code,P.Prod_cat,T.Store_type,SUM(CAST (T.total_amt AS FLOAT)) AS[TOTAL AMOUNT] from prod_cat_info P
LEFT JOIN TRANSACTIONS T
ON P.prod_cat_code=T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
WHERE P.prod_cat IN('Electronics','Clothing') AND Store_type = 'Flagship store'
group by P.prod_cat_code,P.prod_cat,T.Store_type;

--Question9--

SELECT T.Prod_subcat_code,P.Prod_cat,C.Gender,SUM(CAST(T.TOTAL_AMT AS FLOAT)) as [Total revenue generated] FROM Transactions T
LEFT JOIN prod_cat_info P 
ON T.prod_cat_code = p.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
left join Customer C
ON T.cust_id = C.customer_Id
GROUP BY T.prod_subcat_code,C.Gender,P.prod_cat
HAVING P.prod_cat = 'Electronics' AND C.Gender = 'M'
ORDER BY T.prod_subcat_code DESC;

--Question10--


SELECT TOP 5 
P.PROD_SUBCAT, ROUND(SUM(CAST(T.TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(T.TOTAL_AMT AS FLOAT)) FROM TRANSACTIONS T)*100,2) AS PERCANTAGE_OF_SALES, 
ROUND(COUNT(CASE WHEN T.QTY< 0 THEN T.QTY ELSE NULL END)/SUM(CAST(T.QTY AS FLOAT))*100,2) AS PERCENTAGE_OF_RETURN
FROM TRANSACTIONS T
INNER JOIN PROD_CAT_INFO P ON T.PROD_CAT_CODE = P.PROD_CAT_CODE AND T.PROD_SUBCAT_CODE= P.PROD_SUB_CAT_CODE
GROUP BY PROD_SUBCAT
ORDER BY SUM(CAST(TOTAL_AMT AS FLOAT)) DESC

--Question11--

SELECT Customer_id,DATEDIFF(YY,CONVERT(DATE,DOB,103),GETDATE()) AS [Customer converted Age],sum(cast(T.total_amt as float)) as [Total revenue] FROM CUSTOMER C
inner JOIN TRANSACTIONS T
ON C.CUSTOMER_ID = T.cust_id
WHERE cust_id in( select customer_Id from customer where DATEDIFF(Year,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35) and
datediff(day,CONVERT(DATE,tran_date,103),(select max(tran_date) from transactions)) <=30
GROUP BY DATEDIFF(YY,CONVERT(DATE,DOB,103),GETDATE()),customer_Id
order by [Total revenue] desc;


-----DIMANGGHUM GYA NA BABA SEE BELOW IT WAS EASY WITHOUT ANY SUBQUERY PURELY MADE BY YOURSELF------

SELECT Customer_id,DATEDIFF(YY,CONVERT(DATE,DOB,103),GETDATE()) AS [Customer converted Age],sum(cast(T.total_amt as float)) as [Total revenue] FROM CUSTOMER C
inner JOIN TRANSACTIONS T
ON C.CUSTOMER_ID = T.cust_id
WHERE  DATEDIFF(Year,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35 and
datediff(day,CONVERT(DATE,tran_date,103),(select max(tran_date) from transactions)) <=30
GROUP BY DATEDIFF(YY,CONVERT(DATE,DOB,103),GETDATE()),customer_Id
order by [Total revenue] desc;



--Question12--

select top 1 p.Prod_cat,SUM(CAST(t.total_amt AS FLOAT)) as [Maximum value of return] from prod_cat_info p
inner join Transactions t
on p.prod_cat_code = t.prod_cat_code and p.prod_sub_cat_code =t.prod_subcat_code
where  t.Qty<0 and datediff(MONTH,tran_date,(select max(tran_date) from transactions)) <=3
group by p.prod_cat
order by [Maximum value of return] desc;

--Question13--

SELECT  TOP 1 T.Store_type,SUM(CAST(T.QTY AS float)) AS [Quantity sold],SUM(CAST(T.total_amt AS FLOAT)) as [Sales amount] FROM Transactions T
GROUP BY T.Store_type
ORDER BY SUM(CAST(T.QTY AS float)) DESC,SUM(CAST(T.total_amt AS FLOAT)) DESC

--Question14--

select P.Prod_cat,AVG(CAST(T.total_amt AS FLOAT)) AS Average from prod_cat_info P
left join Transactions T
ON P.prod_cat_code = t.prod_cat_code and P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY P.prod_cat
having AVG(CAST(T.total_amt AS FLOAT))>(select AVG(CAST(T.total_amt AS FLOAT)) from transactions t) ;

------- see having part has something new for you---

SELECT AVG(CAST(TOTAL_AMT AS FLOAT)) FROM Transactions


--Question15--


SELECT  PROD_CAT, PROD_SUBCAT, AVG(cast(t.TOTAL_AMT as float)) AS AVERAGE_REV, SUM(cast(TOTAL_AMT as float)) AS REVENUE
FROM TRANSACTIONS T
INNER JOIN PROD_CAT_INFO P ON T.prod_cat_code=P.prod_cat_code AND PROD_SUB_CAT_CODE=PROD_SUBCAT_CODE
WHERE PROD_CAT IN(SELECT TOP 5 
PROD_CAT
FROM TRANSACTIONS T 
INNER JOIN PROD_CAT_INFO P ON T.prod_cat_code= P.prod_cat_code AND T.prod_subcat_code = T.prod_subcat_code
GROUP BY PROD_CAT
ORDER BY SUM(cast(t.QTY as float)) DESC)
GROUP BY PROD_CAT, PROD_SUBCAT 


