--SQL Advance Case Study												
																		
																		
--Q1--BEGIN															
																		
	select State	
	from DIM_LOCATION as l
	inner join 	FACT_TRANSACTIONS as t
	on l.IDLocation=t.IDLocation
	where date between '01-01-2005' and getdate()												
																		



--Q1--END

--Q2--BEGIN																		
	
	select top 1 State
	from DIM_LOCATION as l
	inner join FACT_TRANSACTIONS as t
	on l.IDLocation=t.IDLocation
	inner join DIM_MODEL as m
	on t.IDModel = m.IDModel
	inner join DIM_MANUFACTURER as f
	on f.IDManufacturer= m.IDManufacturer
	where Manufacturer_Name = 'Samsung'
	group by State
	order by sum(Quantity) desc







--Q2--END

--Q3--BEGIN      
	

	select Model_Name, ZipCode, State, count(*) as #_of_Transactions
	from FACT_TRANSACTIONS as t
	inner join DIM_MODEL as m
	on t.IDModel=m.IDModel
	inner join DIM_LOCATION as l
	on t.IDLocation=l.IDLocation
	group by Model_Name, ZipCode, State








--Q3--END

--Q4--BEGIN

	select top 1  IDModel, Manufacturer_Name, Model_Name, Unit_price
	from DIM_MODEL as m
	inner join DIM_MANUFACTURER as f
	on m.IDManufacturer=f.IDManufacturer
	group by IDModel, Manufacturer_Name, Model_Name, Unit_price
	order by Unit_price 

	






--Q4--END

--Q5--BEGIN

	select Model_Name, avg(Unit_price) as Avg_Price
	from DIM_MODEL as m
	inner join DIM_MANUFACTURER as f
	on m.IDManufacturer=f.IDManufacturer
	where Manufacturer_name in 

	(select top 5 Manufacturer_Name
	from FACT_TRANSACTIONS as t 
	inner join DIM_MODEL as m
	on t.IDModel=m.IDModel
	inner join DIM_MANUFACTURER as f
	on f.IDManufacturer=m.IDManufacturer
	group by Manufacturer_Name
	order by sum(Quantity))

	group by Model_Name
	order by Avg_Price desc











--Q5--END

--Q6--BEGIN

	select Customer_Name, avg(TotalPrice) as Avg_Spent
	from DIM_CUSTOMER as c
	inner join FACT_TRANSACTIONS as t
	on c.IDCustomer=t.IDCustomer
	where year(date)=2009
	group by Customer_Name
	having avg(TotalPrice)>500









--Q6--END
	
--Q7--BEGIN

	select IDModel
	from (select t.IDModel, year(date) as yyyy, count(*) as cnt,
          rank() over (partition by year(date) order by count(*) desc) as seqnum
    from FACT_TRANSACTIONS t
    group by IDModel, year(date) 
     ) m
	where seqnum <= 5 and yyyy in (2008, 2009, 2010)
	group by IDModel
	having count(*) = 3


	






--Q7--END	
--Q8--BEGIN

	with rank1 as 
    (
        select MANUFACTURER_NAME,year(Date) as year,
        dense_rank() over (partition by year(date) order by sum(TotalPrice)desc) as rank
        from FACT_TRANSACTIONS as t
        inner join DIM_MODEL as m
        on t.IDMODEL = m.IDModel
        inner join DIM_MANUFACTURER as f
        on f.IDManufacturer = m.IDManufacturer
        group by Manufacturer_Name, year(Date)
    )
    select year, MANUFACTURER_NAME
    from rank1
    where year in ('2009','2010') and rank='2'








--Q8--END
--Q9--BEGIN
	
	select Manufacturer_Name 
	from DIM_MANUFACTURER as f
	inner join DIM_MODEL as m 
	on f.IDMANUFACTURER= m.IDMANUFACTURER
	inner join FACT_TRANSACTIONS as t 
	on m.IDMODEL= t.IDMODEL
	where year(Date) = 2010 
	except 
	select MANUFACTURER_NAME 
	from DIM_MANUFACTURER as f
	inner join DIM_MODEL as m 
	on f.IDMANUFACTURER= m.IDMANUFACTURER
	inner join FACT_TRANSACTIONS as t 
	on m.IDMODEL= t.IDMODEL
	where year(Date) = 2009
















--Q9--END

--Q10--BEGIN
	

	SELECT 
    T1.Customer_Name, T1.Year, T1.Avg_Spend,T1.Avg_Qty,
    CASE
        WHEN T2.Year IS NOT NULL
        THEN FORMAT(CONVERT(DECIMAL(8,2),(T1.Avg_Spend-T2.Avg_Spend))/CONVERT(DECIMAL(8,2),T2.Avg_Spend),'p') ELSE NULL 
        END AS '%_OF_CHANGE'
    FROM
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Spend, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 100 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date)
        )T1
    left join
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Spend, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 100 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date)
        )T2
        on T1.Customer_Name=T2.Customer_Name and T2.YEAR=T1.YEAR-1 











--Q10--END
	