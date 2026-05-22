
--Ventas ($) por periodo: año y mes
SELECT  YEAR(soh.OrderDate) Año,MONTH(soh.OrderDate) Mes,DATENAME(MONTH, soh.OrderDate) NombreMes, SUM(sod.LineTotal) TotalVentas
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate),MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
ORDER BY Año , Mes 

-- (MoM - Month over Month %) de ventas 
SELECT  YEAR(soh.OrderDate) Año, MONTH(soh.OrderDate) Mes,DATENAME(MONTH, soh.OrderDate) NombreMes, SUM(sod.LineTotal) TotalVentas,
MesAnterior = LAG(SUM(sod.LineTotal)) OVER(ORDER BY YEAR(soh.OrderDate) DESC ,MONTH(soh.OrderDate)),
MoM = ROUND( 
		( SUM(sod.LineTotal)  -  LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate) , MONTH(soh.OrderDate)) ) * 100.0
		/ LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate) ,MONTH(soh.OrderDate)) , 2
	)
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate),MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)

-- (YoY - Year over Year %) de ventas
SELECT  YEAR(soh.OrderDate) Año, SUM(sod.LineTotal) TotalVentas,
AnioAnterior = LAG(SUM(sod.LineTotal)) OVER(ORDER BY YEAR(soh.OrderDate) ),
YoY = ROUND( 
		( SUM(sod.LineTotal)  -  LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate)) ) * 100.0
		/ LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate)) , 2
	)
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate);

--Variacion de ventas entre peridodos: año y mes  
WITH VentasMensuales AS (
	SELECT YEAR(soh.OrderDate) Anio,MONTH(soh.OrderDate) NumMes,DATENAME(MONTH, soh.OrderDate) Mes, SUM(sod.LineTotal) Ventas
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY YEAR(soh.OrderDate),MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
)
SELECT *, 
MoM = ROUND( 
		( Ventas  -  LAG(Ventas) OVER(ORDER BY Anio , NumMes) ) * 100.0
		/ LAG(Ventas ) OVER(ORDER BY Anio,NumMes) , 2
	),
YoY = ROUND( 
		( Ventas  -  LAG(Ventas,12 ) OVER(ORDER BY Anio, NumMes) ) * 100.0
		/ LAG( Ventas,12) OVER(ORDER BY Anio,NumMes ),2
	)
FROM VentasMensuales;


--Tasa de crecimiento promedio(simple) anual
WITH VentasAnuales AS(
SELECT  YEAR(soh.OrderDate) Anio, SUM(sod.LineTotal) TotalVentas,
AnioAnterior = LAG(SUM(sod.LineTotal)) OVER(ORDER BY YEAR(soh.OrderDate)),
YoY = ( 
		( SUM(sod.LineTotal)  -  LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate) ) ) * 100.0
		/ LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate) ) 
	)
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate)
)
SELECT AVG(YoY) TasaCrecimientoPromedio
FROM VentasAnuales;

--Tasa de crecimiento promedio (simple) mensual
WITH VentasMensuales AS(
SELECT  YEAR(soh.OrderDate) Año, MONTH(soh.OrderDate) Mes,DATENAME(MONTH, soh.OrderDate) NombreMes, SUM(sod.LineTotal) TotalVentas,
MesAnterior = LAG(SUM(sod.LineTotal)) OVER(ORDER BY YEAR(soh.OrderDate) ,MONTH(soh.OrderDate)),
MoM = ( 
		( SUM(sod.LineTotal)  -  LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate) , MONTH(soh.OrderDate)) ) * 100.0
		/ LAG( SUM(sod.LineTotal) ) OVER(ORDER BY YEAR(soh.OrderDate) ,MONTH(soh.OrderDate))
	)
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate),MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
)
SELECT AVG(MoM) TasaCrecimientoPromedio
FROM VentasMensuales
WHERE MoM IS NOT NULL;

--Moving average de ventas anual (considera menos de 12 meses)
SELECT  YEAR(soh.OrderDate) Año,DATENAME(MONTH, soh.OrderDate) NombreMes,
MovingAverageAnual = ROUND( 
	AVG( SUM(sod.LineTotal) )  OVER(ORDER BY  YEAR(soh.OrderDate) ,MONTH(soh.OrderDate) ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2
)
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)

--Moving average de ventas anual (considera solo 12 meses completos)
SELECT  YEAR(soh.OrderDate) Año, DATENAME(MONTH, soh.OrderDate) Mes,
	MovingAverageAnual = 
		CASE WHEN COUNT(*) OVER (ORDER BY YEAR(soh.OrderDate),MONTH(soh.OrderDate) ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) = 12
			 THEN ROUND( AVG( SUM(sod.LineTotal) )  OVER( ORDER BY YEAR(soh.OrderDate) , MONTH(soh.OrderDate)  ROWS BETWEEN 11 PRECEDING AND CURRENT ROW),2 )
		END 
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)

--Moving average de ventas cada 3 meses
SELECT  YEAR(soh.OrderDate) Año, DATENAME(MONTH, soh.OrderDate) Mes,
	MovingAverage3Meses = 
		CASE WHEN COUNT(*) OVER (ORDER BY YEAR(soh.OrderDate), MONTH(soh.OrderDate) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
			 THEN ROUND( AVG( SUM(sod.LineTotal) )  OVER( ORDER BY YEAR(soh.OrderDate) , MONTH(soh.OrderDate)  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2 )
		END 
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
