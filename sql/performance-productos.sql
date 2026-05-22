
--Ventas totales por producto ($)
SELECT p.Name Producto ,SUM(sod.LineTotal) Ventas
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.ProductID,p.Name

--Cantidad total de unidades vendidas
SELECT COUNT(sod.OrderQty) CantidadVendida
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID

--Precio promedio de venta
SELECT AVG(TotalPedido) PromedioTransaccion
FROM(
	SELECT soh.SalesOrderID, SUM(sod.LineTotal) TotalPedido
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY soh.SalesOrderID
) x
 
--Ranking de productos mas vendidos (por unidades)
SELECT p.Name Producto ,COUNT(sod.OrderQty) CantidadVendida
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY CantidadVendida DESC

--Participacion porcentual del producto en las ventas (por revenue)
WITH VentasPorProducto AS (
	SELECT p.ProductID,p.Name Producto ,SUM(sod.LineTotal) Ventas
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product p ON sod.ProductID = p.ProductID
	GROUP BY p.ProductID ,p.Name
)
SELECT Producto, Ventas,
PcteParticipacion = ROUND (Ventas * 100.0 / SUM(Ventas) OVER() ,2)
FROM VentasPorProducto
ORDER BY PcteParticipacion DESC;

--Rentabilidad de los productos vendidos(ingresos - costos)
SELECT p.Name Producto,SUM(sod.LineTotal) Ingreso , SUM(sod.OrderQty * p.StandardCost) Costo,
Rentabilidad = SUM(sod.LineTotal) -  SUM(sod.OrderQty * p.StandardCost)
INTO #Rentabilidad
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY p.Name

SELECT * FROM #Rentabilidad

--Listado de productos con su volumen de ventas vs su rentabilidad 
SELECT p.Name Producto ,SUM(sod.OrderQty) UnidVendidas, r.Rentabilidad
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN #Rentabilidad r ON p.Name = r.Producto
GROUP BY p.Name, r.Rentabilidad