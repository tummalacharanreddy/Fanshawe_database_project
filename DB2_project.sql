USE [MyGuitarShop]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateTotalOrderAmount]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[CalculateTotalOrderAmount](@customerId INT)
RETURNS MONEY
AS
BEGIN
  DECLARE @totalAmount MONEY;
  
  SELECT @totalAmount = SUM(ItemPrice - DiscountAmount)
  FROM OrderItems
  WHERE OrderID IN (
    SELECT OrderID
    FROM Orders
    WHERE CustomerID = @customerId
  );
  
  RETURN @totalAmount;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetOrderCountByCustomer]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetOrderCountByCustomer](@customerId INT)
RETURNS INT
AS
BEGIN
  DECLARE @orderCount INT;
  
  SELECT @orderCount = COUNT(*)
  FROM Orders
  WHERE CustomerID = @customerId;
  
  RETURN @orderCount;
END;
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[OrderDate] [datetime] NOT NULL,
	[ShipAmount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[ShipDate] [datetime] NULL,
	[ShipAddressID] [int] NOT NULL,
	[CardType] [varchar](50) NOT NULL,
	[CardNumber] [char](16) NOT NULL,
	[CardExpires] [char](7) NOT NULL,
	[BillingAddressID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CustomersView]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CustomersView]
AS
  select cardType, count(*) AS No_of_Cards from [Orders] group by cardType;
GO
/****** Object:  Table [dbo].[Products]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NULL,
	[ProductCode] [varchar](10) NOT NULL,
	[ProductName] [varchar](255) NOT NULL,
	[Description] [text] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[DiscountPercent] [money] NOT NULL,
	[DateAdded] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetProductsByCategory]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[GetProductsByCategory](@categoryId INT)
RETURNS TABLE
AS
RETURN (
  SELECT *
  FROM Products
  WHERE CategoryID = @categoryId
);
GO
/****** Object:  UserDefinedFunction [dbo].[SearchProductsByKeyword]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[SearchProductsByKeyword](@keyword VARCHAR(255))
RETURNS TABLE
AS
RETURN (
  SELECT *
  FROM Products
  WHERE ProductName LIKE '%' + @keyword + '%'
    OR Description LIKE '%' + @keyword + '%'
);
GO
/****** Object:  Table [dbo].[OrderItems]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderItems](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[ProductID] [int] NULL,
	[ItemPrice] [money] NOT NULL,
	[DiscountAmount] [money] NOT NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OrderDetails]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrderDetails] AS
SELECT o.OrderID, o.OrderDate, o.TaxAmount, o.ShipDate,
       oi.ItemPrice, oi.DiscountAmount, (oi.ItemPrice - oi.DiscountAmount) AS FinalPrice,
       oi.Quantity, (oi.ItemPrice - oi.DiscountAmount) * oi.Quantity AS ItemTotal,
       p.ProductName
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID;
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 7/21/2023 1:42:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[EmailAddress] [varchar](255) NOT NULL,
	[Password] [varchar](60) NOT NULL,
	[FirstName] [varchar](60) NOT NULL,
	[LastName] [varchar](60) NOT NULL,
	[ShippingAddressID] [int] NULL,
	[BillingAddressID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Addresses]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Addresses](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[Line1] [varchar](60) NOT NULL,
	[Line2] [varchar](60) NULL,
	[City] [varchar](40) NOT NULL,
	[State] [varchar](2) NOT NULL,
	[ZipCode] [varchar](10) NOT NULL,
	[Phone] [varchar](12) NOT NULL,
	[Disabled] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CustomerAddresses]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CustomerAddresses] AS
SELECT c.CustomerID, c.EmailAddress, c.LastName, c.FirstName,
       ba.Line1 AS BillLine1, ba.Line2 AS BillLine2, ba.City AS BillCity, ba.State AS BillState, ba.ZipCode AS BillZip,
       sa.Line1 AS ShipLine1, sa.Line2 AS ShipLine2, sa.City AS ShipCity, sa.State AS ShipState, sa.ZipCode AS ShipZip
FROM Customers c
JOIN Addresses ba ON c.BillingAddressID = ba.AddressID
JOIN Addresses sa ON c.ShippingAddressID = sa.AddressID;
GO
/****** Object:  View [dbo].[OrderItemProducts]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OrderItemProducts] AS
SELECT o.OrderID, o.OrderDate, o.TaxAmount, o.ShipDate,
       oi.ItemPrice, oi.DiscountAmount, (oi.ItemPrice - oi.DiscountAmount) AS FinalPrice,
       oi.Quantity, (oi.ItemPrice - oi.DiscountAmount) * oi.Quantity AS ItemTotal,
       p.ProductName
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID;
GO
/****** Object:  View [dbo].[ProductSummary]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ProductSummary] AS
SELECT p.ProductName, COUNT(oi.OrderID) AS OrderCount, SUM(oi.ItemTotal) AS OrderTotal
FROM OrderItemProducts oi
JOIN Products p ON oi.ProductName = p.ProductName
GROUP BY p.ProductName;
GO
/****** Object:  Table [dbo].[Administrators]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Administrators](
	[AdminID] [int] IDENTITY(1,1) NOT NULL,
	[EmailAddress] [varchar](255) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[FirstName] [varchar](255) NOT NULL,
	[LastName] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CategoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerOrders]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerOrders](
	[CustomerID] [int] NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[ShippingAddressLine1] [varchar](100) NULL,
	[ShippingAddressLine2] [varchar](100) NULL,
	[ShippingCity] [varchar](50) NULL,
	[ShippingState] [varchar](50) NULL,
	[ShippingZipCode] [varchar](10) NULL,
	[BillingAddressLine1] [varchar](100) NULL,
	[BillingAddressLine2] [varchar](100) NULL,
	[BillingCity] [varchar](50) NULL,
	[BillingState] [varchar](50) NULL,
	[BillingZipCode] [varchar](10) NULL,
	[OrderID] [int] NULL,
	[OrderDate] [date] NULL,
	[ShipAmount] [decimal](10, 2) NULL,
	[TaxAmount] [decimal](10, 2) NULL,
	[ShipDate] [date] NULL,
	[CardType] [varchar](20) NULL,
	[CardNumber] [varbinary](256) NULL,
	[CardExpires] [varchar](10) NULL,
	[ShipAddressLine1] [varchar](100) NULL,
	[ShipAddressLine2] [varchar](100) NULL,
	[ShipCity] [varchar](50) NULL,
	[ShipState] [varchar](50) NULL,
	[ShipZipCode] [varchar](10) NULL,
	[ItemID] [int] NULL,
	[ProductID] [int] NULL,
	[ProductCode] [varchar](20) NULL,
	[ProductName] [varchar](100) NULL,
	[ItemPrice] [decimal](10, 2) NULL,
	[DiscountAmount] [decimal](10, 2) NULL,
	[Quantity] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Downloads]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Downloads](
	[DownloadID] [int] NOT NULL,
	[FileName] [varchar](255) NULL,
	[UserID] [int] NULL,
	[ProductID] [int] NULL,
	[DownloadDateTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DownloadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PermanentCustomerOrders]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermanentCustomerOrders](
	[CustomerID] [int] NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[ShippingAddressLine1] [varchar](100) NULL,
	[ShippingAddressLine2] [varchar](100) NULL,
	[ShippingCity] [varchar](50) NULL,
	[ShippingState] [varchar](50) NULL,
	[ShippingZipCode] [varchar](10) NULL,
	[BillingAddressLine1] [varchar](100) NULL,
	[BillingAddressLine2] [varchar](100) NULL,
	[BillingCity] [varchar](50) NULL,
	[BillingState] [varchar](50) NULL,
	[BillingZipCode] [varchar](10) NULL,
	[OrderID] [int] NULL,
	[OrderDate] [date] NULL,
	[ShipAmount] [decimal](10, 2) NULL,
	[TaxAmount] [decimal](10, 2) NULL,
	[ShipDate] [date] NULL,
	[CardType] [varchar](20) NULL,
	[CardNumber] [varbinary](256) NULL,
	[CardExpires] [date] NULL,
	[ShipAddressLine1] [varchar](100) NULL,
	[ShipAddressLine2] [varchar](100) NULL,
	[ShipCity] [varchar](50) NULL,
	[ShipState] [varchar](50) NULL,
	[ShipZipCode] [varchar](10) NULL,
	[ItemID] [int] NULL,
	[ProductID] [int] NULL,
	[ProductCode] [varchar](20) NULL,
	[ProductName] [varchar](100) NULL,
	[ItemPrice] [decimal](10, 2) NULL,
	[DiscountAmount] [decimal](10, 2) NULL,
	[Quantity] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TempCustomerOrders]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempCustomerOrders](
	[CustomerID] [int] NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[ShippingAddressLine1] [varchar](100) NULL,
	[ShippingAddressLine2] [varchar](100) NULL,
	[ShippingCity] [varchar](50) NULL,
	[ShippingState] [varchar](50) NULL,
	[ShippingZipCode] [varchar](10) NULL,
	[BillingAddressLine1] [varchar](100) NULL,
	[BillingAddressLine2] [varchar](100) NULL,
	[BillingCity] [varchar](50) NULL,
	[BillingState] [varchar](50) NULL,
	[BillingZipCode] [varchar](10) NULL,
	[OrderID] [int] NULL,
	[OrderDate] [date] NULL,
	[ShipAmount] [decimal](10, 2) NULL,
	[TaxAmount] [decimal](10, 2) NULL,
	[ShipDate] [date] NULL,
	[CardType] [varchar](20) NULL,
	[CardNumber] [varchar](16) NULL,
	[CardExpires] [varchar](10) NULL,
	[ShipAddressLine1] [varchar](100) NULL,
	[ShipAddressLine2] [varchar](100) NULL,
	[ShipCity] [varchar](50) NULL,
	[ShipState] [varchar](50) NULL,
	[ShipZipCode] [varchar](10) NULL,
	[ItemID] [int] NULL,
	[ProductID] [int] NULL,
	[ProductCode] [varchar](20) NULL,
	[ProductName] [varchar](100) NULL,
	[ItemPrice] [decimal](10, 2) NULL,
	[DiscountAmount] [decimal](10, 2) NULL,
	[Quantity] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] NOT NULL,
	[EmailAddress] [varchar](255) NULL,
	[FirstName] [varchar](255) NULL,
	[LastName] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT (NULL) FOR [Line2]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT ((0)) FOR [Disabled]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (NULL) FOR [ShippingAddressID]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (NULL) FOR [BillingAddressID]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT (NULL) FOR [ShipDate]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0.00)) FOR [DiscountPercent]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (NULL) FOR [DateAdded]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Downloads]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Downloads]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO
/****** Object:  StoredProcedure [dbo].[Addresses_list]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Addresses_list] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM dbo.Addresses;
END
GO
/****** Object:  StoredProcedure [dbo].[ExportCustomersToCSV]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Create the stored procedure
-- Create the stored procedure
CREATE   PROCEDURE [dbo].[ExportCustomersToCSV]
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables for the file path and other options
    DECLARE @FilePath NVARCHAR(500);
    DECLARE @FileName NVARCHAR(255);
    DECLARE @Command NVARCHAR(1000);
    DECLARE @ErrorMessage NVARCHAR(1000);

    -- Set the file path and name with the current date
    SET @FilePath = 'C:\backup\'; -- Specify the directory path
    SET @FileName = 'Customers_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 120), ':', '') + '.csv'; -- Add the current date to the file name
    
    -- Concatenate the file path and name
    SET @FilePath = @FilePath + @FileName;

    -- Create the bcp command to export the Customers table to the CSV file
    SET @Command = 'bcp "SELECT * FROM MyGuitarShop.dbo.Customers" queryout "' + @FilePath + '" -c -t, -T -S ' + @@SERVERNAME;

    -- Execute the bcp command
    BEGIN TRY
        EXEC xp_cmdshell @Command;
        PRINT 'Customers table exported to CSV file: ' + @FileName;
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error exporting Customers table to CSV file: ' + @ErrorMessage;
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerOrderDetails]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerOrderDetails]
  @customerId INT
AS
BEGIN
  -- Declare variables
  DECLARE @totalOrderAmount MONEY;
  DECLARE @orderCount INT;

  -- Get total order amount using CalculateTotalOrderAmount function
  SELECT @totalOrderAmount = dbo.CalculateTotalOrderAmount(@customerId);

  -- Get order count using GetOrderCountByCustomer function
  SELECT @orderCount = dbo.GetOrderCountByCustomer(@customerId);

  -- Return the results
  SELECT 
    @customerId AS CustomerID,
    @totalOrderAmount AS TotalOrderAmount,
    @orderCount AS OrderCount;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerOrders]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerOrders] 
  @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve customer information
    SELECT
        C.CustomerID,
        C.FirstName,
        C.LastName,
        A.Line1 AS ShippingAddressLine1,
        A.Line2 AS ShippingAddressLine2,
        A.City AS ShippingCity,
        A.State AS ShippingState,
        A.ZipCode AS ShippingZipCode,
        B.Line1 AS BillingAddressLine1,
        B.Line2 AS BillingAddressLine2,
        B.City AS BillingCity,
        B.State AS BillingState,
        B.ZipCode AS BillingZipCode
    FROM
        Customers C
    LEFT JOIN
        Addresses A ON C.ShippingAddressID = A.AddressID
    LEFT JOIN
        Addresses B ON C.BillingAddressID = B.AddressID
    WHERE
        C.CustomerID = @CustomerID;

    -- Retrieve orders for the customer
    SELECT
        O.OrderID,
        O.OrderDate,
        O.ShipAmount,
        O.TaxAmount,
        O.ShipDate,
        O.CardType,
        O.CardNumber,
        O.CardExpires,
        A.Line1 AS ShipAddressLine1,
        A.Line2 AS ShipAddressLine2,
        A.City AS ShipCity,
        A.State AS ShipState,
        A.ZipCode AS ShipZipCode
    FROM
        Orders O
    INNER JOIN
        Addresses A ON O.ShipAddressID = A.AddressID
    WHERE
        O.CustomerID = @CustomerID;

    -- Retrieve order items for each order
    DECLARE @OrderID INT;

    DECLARE OrderCursor CURSOR FOR
    SELECT OrderID
    FROM Orders
    WHERE CustomerID = @CustomerID;

    OPEN OrderCursor;
    FETCH NEXT FROM OrderCursor INTO @OrderID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Retrieve order items for the current order
        SELECT
            OI.ItemID,
            OI.ProductID,
            P.ProductCode,
            P.ProductName,
            OI.ItemPrice,
            OI.DiscountAmount,
            OI.Quantity
        FROM
            OrderItems OI
        INNER JOIN
            Products P ON OI.ProductID = P.ProductID
        WHERE
            OI.OrderID = @OrderID;

        FETCH NEXT FROM OrderCursor INTO @OrderID;
    END;

    CLOSE OrderCursor;
    DEALLOCATE OrderCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertCategoriesFromCSV]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[InsertCategoriesFromCSV]
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        BULK INSERT Categories
        FROM ''' + @FilePath + '''
        WITH (
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n''
        );';

    EXEC sp_executesql @SQL;
END
GO
/****** Object:  StoredProcedure [dbo].[tempCustomerOrder]    Script Date: 7/21/2023 1:42:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[tempCustomerOrder]
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert the combined data into the permanent table for new records
    INSERT INTO dbo.CustomerOrders (
        CustomerID,
        FirstName,
        LastName,
        ShippingAddressLine1,
        ShippingAddressLine2,
        ShippingCity,
        ShippingState,
        ShippingZipCode,
        BillingAddressLine1,
        BillingAddressLine2,
        BillingCity,
        BillingState,
        BillingZipCode,
        OrderID,
        OrderDate,
        ShipAmount,
        TaxAmount,
        ShipDate,
        CardType,
        CardNumber,
        CardExpires,
        ShipAddressLine1,
        ShipAddressLine2,
        ShipCity,
        ShipState,
        ShipZipCode,
        ItemID,
        ProductID,
        ProductCode,
        ProductName,
        ItemPrice,
        DiscountAmount,
        Quantity
    )
    SELECT
        C.CustomerID,
        C.FirstName,
        C.LastName,
        A.Line1 AS ShippingAddressLine1,
        A.Line2 AS ShippingAddressLine2,
        A.City AS ShippingCity,
        A.State AS ShippingState,
        A.ZipCode AS ShippingZipCode,
        B.Line1 AS BillingAddressLine1,
        B.Line2 AS BillingAddressLine2,
        B.City AS BillingCity,
        B.State AS BillingState,
        B.ZipCode AS BillingZipCode,
        O.OrderID,
        O.OrderDate,
        O.ShipAmount,
        O.TaxAmount,
        O.ShipDate,
        O.CardType,
        ENCRYPTBYKEY(KEY_GUID('CustomerOrdersCardKey'), CONVERT(VARBINARY(256), O.CardNumber)), -- Encrypt the CardNumber column
        CONVERT(VARCHAR(10), O.CardExpires, 120), -- Explicitly convert CardExpires to VARCHAR format
        A.Line1 AS ShipAddressLine1,
        A.Line2 AS ShipAddressLine2,
        A.City AS ShipCity,
        A.State AS ShipState,
        A.ZipCode AS ShipZipCode,
        OI.ItemID,
        OI.ProductID,
        P.ProductCode,
        P.ProductName,
        OI.ItemPrice,
        OI.DiscountAmount,
        OI.Quantity
    FROM
        Customers C
    LEFT JOIN
        Addresses A ON C.ShippingAddressID = A.AddressID
    LEFT JOIN
        Addresses B ON C.BillingAddressID = B.AddressID
    INNER JOIN
        Orders O ON C.CustomerID = O.CustomerID
    INNER JOIN
        OrderItems OI ON O.OrderID = OI.OrderID
    INNER JOIN
        Products P ON OI.ProductID = P.ProductID
    WHERE
        NOT EXISTS (
            SELECT 1
            FROM dbo.CustomerOrders CO
            WHERE CO.CustomerID = C.CustomerID
                AND CO.OrderID = O.OrderID
                AND CO.ItemID = OI.ItemID
        );

END;
GO
