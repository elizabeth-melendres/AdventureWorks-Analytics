--Ventas totales (todos los años) 
SELECT SUM(sod.LineTotal) TotalVentas
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID

--Ventas totales ($) por año
SELECT YEAR(soh.OrderDate) Anio, SUM(sod.LineTotal) TotalVentas
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate)
ORDER BY Anio DESC

--Ventas totales ($) por mes
SELECT  YEAR(soh.OrderDate) Año,MONTH(soh.OrderDate) Mes,DATENAME(MONTH, soh.OrderDate) NombreMes, SUM(sod.OrderQty * sod.UnitPrice) TotalVentas
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate),MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
ORDER BY Año DESC, Mes 

--Promedio ($) de la transaccion
SELECT AVG(TotalPedido) PromedioTransaccion
FROM(
	SELECT SUM(sod.LineTotal) TotalPedido
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
) x

--Numero de ventas
SELECT COUNT(*) NumeroVentas
FROM Sales.SalesOrderHeader soh

--Cantidad productos vendidos (en total)
SELECT SUM(sod.OrderQty) ProductosVendidos
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID

--Top 10 productos por ventas($)
SELECT TOP 10 p.Name, SUM(sod.OrderQty * sod.UnitPrice) TotalVentas 
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p on sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalVentas DESC

--Top categoria de productos por ventas($)
SELECT TOP 10 pc.Name, SUM(sod.OrderQty * sod.UnitPrice) TotalVentas 
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p on sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY TotalVentas DESC

