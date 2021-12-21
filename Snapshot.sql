--Crear el Snapshot
CREATE DATABASE [NesDS_SS_2] ON 
(NAME = NestleDS,
FILENAME = 'C:\dbData\AWss_Data.mdf' )
AS SNAPSHOT OF AdventureWorks
GO

USE AdventureWorks
GO

--Recuperando una fila borrada
DELETE Production.WorkOrderRouting
INSERT INTO Production.WorkOrderRouting
SELECT * FROM AWss.Production.WorkOrderRouting
GO

--deshaciendo una actualizacion
UPDATE HumanResources.Department
SET Name = (SELECT Name FROM AWss.HumanResources.Department
            WHERE DepartmentID = 1)
WHERE DepartmentID = 1
GO

--Recuperando un objeto
--Generar Script desde AWss
--si es una tabla, copiar datos

--restaurando desde un Snapshot
USE master
GO
RESTORE DATABASE AdventureWorks
FROM DATABASE_SNAPSHOT = 'AWss'
GO

DROP DATABASE AWss 