--*************************************************************************--
-- Title: Assignment06
-- Author: KrisCzaja
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-05-23,KrisCzaja,Updated File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KrisCzaja')
	 Begin 
	  Alter Database [Assignment06DB_KrisCzaja] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KrisCzaja;
	 End
	Create Database Assignment06DB_KrisCzaja;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KrisCzaja;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Go
Create 
View vCategories
With Schemabinding
 AS 
  Select CategoryID, CategoryName From dbo.Categories;
Go

Create 
View vProducts
With Schemabinding
 AS 
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
Go

Create 
View vEmployees
With Schemabinding
 As 
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
Go

Create 
View vInventories
With Schemabinding
 As 
  Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories;
Go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public
Deny Select On Products to Public;
Grant Select On vProducts to Public
Deny Select On Employees to Public;
Grant Select On vEmployees to Public
Deny Select On Inventories to Public;
Grant Select On vInventories to Public
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create
View vProductsByCategories
 As
  Select Top 1000000
  CategoryName, ProductName, UnitPrice
  From Categories
  Join Products
	on Categories.CategoryID = Products.CategoryID
Order by CategoryName, ProductName
Go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create
View vInventoriesByProductsByDates
As
 Select Top 100000000
 ProductName, InventoryDate, Count
 from Products
 Join Inventories
  on Products.ProductID = Inventories.ProductID
Order by ProductName, InventoryDate, Count
Go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create
View vInventoriesByEmployeesByDates
As
Select 
distinct Top 100000
InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
From Inventories
 Join Employees
  On Inventories.EmployeeID = Employees.EmployeeID
Order by InventoryDate
Go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vInventoriesByProductsByCategories
As
Select Top 10000
c.CategoryName, p.ProductName, i.InventoryDate, i.Count
From Categories as c
Join Products as p
On c.CategoryID = p.CategoryID
Join Inventories as i
On p.ProductID = i.ProductID
Order by c.CategoryName, p.ProductName, i.InventoryDate, i.Count
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees
As
Select Top 100000
c.CategoryName, p.ProductName, i.InventoryDate, i.Count, e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
From Categories as c
Join Products as p
On c.CategoryID = p.CategoryID
Join Inventories as i
On p.ProductID = i.ProductID
Join Employees as e
On i.EmployeeID = e.EmployeeID
Order by i.InventoryDate, c.CategoryName, p.ProductName, Employee
Go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees
As
Select Top 10000
c.CategoryName, p.ProductName, i.InventoryDate, i.Count, e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
From Categories as c
Join Products as p
On c.CategoryID = p.CategoryID
Join Inventories as i
On p.ProductID = i.ProductID
Join Employees as e
On i.EmployeeID = e.EmployeeID
Where p.ProductID in (
	Select ProductID
	From Products
	Where ProductName in ('Chai','Chang')
)
Order by i.InventoryDate, c.CategoryName, p.ProductName, Employee -- This is not part of the question, but makes the results match the answer from Module06 document
Go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!


Create View vEmployeesByManager
As
Select Top 1000
m.EmployeeFirstName + m.EmployeeLastName as Manager, e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
From Employees as e
Join Employees as m
on e.ManagerID = m.EmployeeID
Order by Manager -- Question says to order by manager's name only, but in the assignment document the same question 
-- asks to order by manager and employee - in that case it would be "Order by Manager, Employee"
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View vInventoriesByProductsByCategoriesByEmployees
As
Select Top 100000
vCategories.CategoryID, CategoryName, vProducts.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, vE.EmployeeID,
vE.EmployeeFirstName + ' ' + vE.EmployeeLastName as Employee, vM.EmployeeFirstName + ' ' + vM.EmployeeLastName as Manager

From vCategories
 Join vProducts
  on vCategories.CategoryID = vProducts.CategoryID
 Join vInventories
  on vProducts.ProductID = vInventories.ProductID
 Join vEmployees as vE
  on vInventories.EmployeeID = vE.EmployeeID
Join vEmployees as vM
 on vE.ManagerID = vM.EmployeeID

Order By CategoryName, ProductName, InventoryId, Employee
Go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/