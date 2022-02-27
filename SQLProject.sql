-- Course : DM110821
-- Student name: Shani Kariti
-- Phone : 054-268-6215


use adventureworks2014;
go

-- Exercise 1:
select firstname, lastname, count(*) as AmountOfDepartments
from Person.person p join HumanResources.EmployeeDepartmentHistory edh
on p.BusinessEntityID = edh.BusinessEntityID
group by firstname, lastname
having count(*) > 1;

go

-- Exercise 2: 
select edh.BusinessEntityID, firstname, lastname
from HumanResources.EmployeeDepartmentHistory edh join HumanResources.Department d
on edh.DepartmentID = d.DepartmentID
join Person.person p on p.BusinessEntityID = edh.BusinessEntityID
where enddate is not null
group by edh.BusinessEntityID, firstname, lastname;

go

-- Exercise 3:
select top 1 p.name, sod.productid, count(sod.SalesOrderID) as AmountOfOrders
from sales.SalesOrderDetail sod join Production.Product p 
on p.ProductID = sod.ProductID
group by p.name, sod.productid
order by AmountOfOrders desc;

go

-- Exercise 4:
select top 1 sod.productid, p.name, sum(orderqty) as Amount
from sales.SalesOrderDetail sod join Production.Product p on sod.productid = p.ProductID
group by sod.productid, p.name
order by Amount desc;

go

-- Exercise 5:
select c.*
from sales.Customer c left join sales.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
where SalesOrderID is null;
go

-- Exercise 6:
select p.*
from Production.Product p left join sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
where sod.SalesOrderID is null;

go

-- Exercise 7:
WITH Months(m) as
(
    SELECT 1 m
    UNION ALL 
    SELECT m+1
    FROM Months
    WHERE m <= 12
)
SELECT m [Month], t.*
FROM Months
CROSS APPLY 
(
    SELECT TOP 3
       SalesOrderID, 
       max(TotalDue) Sales
    FROM    sales.SalesOrderHeader
    WHERE  MONTH(orderdate) = Months.m
    GROUP BY SalesOrderID
    ORDER BY 2 DESC
) t

go

-- Exercise 8
select BusinessEntityID, COUNT(salesorderid) as AmountOfSales, YEAR(orderdate) as YearOfSale, MONTH(orderdate) as MonthOfSale
from sales.SalesPerson sp join sales.SalesOrderHeader soh
on sp.BusinessEntityID = soh.SalesPersonID
group by BusinessEntityID, YEAR(orderdate),MONTH(orderdate)
order by AmountOfSales desc, YEAR(orderdate), MONTH(orderdate)

go

-- Exercise 9
select sp.BusinessEntityID, firstname, lastname, sum(SubTotal) as Sales, YEAR(orderdate) as YearOfSale, MONTH(orderdate) as MonthOfSale
from sales.SalesPerson sp join sales.SalesOrderHeader soh
on sp.BusinessEntityID = soh.SalesPersonID
join person.person p on sp.BusinessEntityID = p.BusinessEntityID
group by sp.BusinessEntityID, firstname, lastname, YEAR(orderdate),MONTH(orderdate)
order by Sales, YEAR(orderdate), MONTH(orderdate)

go

-- Exercise 10 
DROP FUNCTION IF EXISTS GetSales

GO
  CREATE FUNCTION GetSales(@SalesManId INTeger,@Year INTeger,@Month INTeger)
    RETURNS TABLE
    AS 
	 
	return SELECT SUM(subtotal) as column1
		FROM sales.SalesOrderHeader
		where YEAR(OrderDate) = (SELECT CASE
                  WHEN @Month <> 1
                     THEN @Year
                  ELSE @Year - 1
				  end) and Month(Orderdate) = (SELECT CASE
                  WHEN @Month <> 1
                     THEN @Month - 1
                  ELSE 12
				  end) and SalesPersonID = @SalesManId	

GO

select sp.BusinessEntityID, firstname, lastname, sum(SubTotal) as Sales, YEAR(orderdate) as YearOfSale, MONTH(orderdate) as MonthOfSale,
(select * from dbo.GetSales(sp.BusinessEntityID,YEAR(orderdate),MONTH(orderdate))) as PrevMonthSales
from sales.SalesPerson sp join sales.SalesOrderHeader soh
on sp.BusinessEntityID = soh.SalesPersonID
join person.person p on sp.BusinessEntityID = p.BusinessEntityID 
group by sp.BusinessEntityID, firstname, lastname, YEAR(orderdate),MONTH(orderdate)
order by Sales, YEAR(orderdate), MONTH(orderdate)

GO

