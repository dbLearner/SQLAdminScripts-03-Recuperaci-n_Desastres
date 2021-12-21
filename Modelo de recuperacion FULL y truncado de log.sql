USE master;
GO

--Asegurese de qu ela ruta E:\bdTest existe en su máquina, si no cámbiela
--Asegurese de tener suficiente espacio en disco (20 MB) para la base de datos y los backups
CREATE DATABASE PruebaLog ON  PRIMARY (  
   NAME = 'PruebaLog', 
   FILENAME = 'E:\bdTest\PruebaLog.mdf' , 
   SIZE = 10240KB, 
   FILEGROWTH = 1024KB )
 LOG ON ( 
  NAME = 'PruebaLog_log', 
  FILENAME = 'E:\bdTest\PruebaLog_log.ldf' , 
  SIZE = 5120KB, 
  FILEGROWTH = 10%)
GO

--Nos aseguramos que el modelo de recuperación es COMPLETO o FULL
ALTER DATABASE PruebaLog SET RECOVERY FULL;
GO

--Ejecutamos un backup completo
BACKUP DATABASE PruebaLog TO DISK = 'E:\bdTest\PruebaLog_Full.bak'
WITH INIT;
GO

--creamos una tabla de prueba
USE PruebaLog;
GO

CREATE TABLE TablaPrueba
( Id int IDENTITY(1,1) PRIMARY KEY,
  Columna1 nvarchar(600),
  Columna2 bigint
);
GO
	
-- Examinamos las propiedades de los archivos de la base de datos
SELECT name AS Archivo,
       size * 8 /1024. AS MB,  
       FILEPROPERTY(name,'SpaceUsed') * 8 /1024. AS MBUsado,
       CAST(FILEPROPERTY(name,'SpaceUsed') AS decimal(10,4))
         / CAST(size AS decimal(10,4)) * 100 AS PctUsado	
FROM sys.database_files;
GO

--Insertamos 5,000 registros de prueba
SET NOCOUNT ON;

INSERT INTO TablaPrueba(Columna1,Columna2)
  VALUES('datos de prueba',12345);
GO 5000

--Volvemos a examinar el archivo de Log
--Nótese que el archivo de log esta más lleno que antes
SELECT name AS Archivo,
       size * 8 /1024. AS MB,  
       FILEPROPERTY(name,'SpaceUsed') * 8 /1024. AS MBUsado,
       CAST(FILEPROPERTY(name,'SpaceUsed') AS decimal(10,4))
         / CAST(size AS decimal(10,4)) * 100 AS PctUsado	
FROM sys.database_files
WHERE type = 1;	
GO	

--Ejecutamos un CHECKPOINT
CHECKPOINT;
GO

--Volvemos a examinar el archivo de Log
--Nótese que con el CHECKPOINT no ha cambiado el espacio utilizado
SELECT name AS Archivo,
       size * 8 /1024. AS MB,  
       FILEPROPERTY(name,'SpaceUsed') * 8 /1024. AS MBUsado,
       CAST(FILEPROPERTY(name,'SpaceUsed') AS decimal(10,4))
         / CAST(size AS decimal(10,4)) * 100 AS PctUsado	
FROM sys.database_files
WHERE type = 1;	
GO	

--Podemos ver que es lo que esta esperando la base de datos para truncar el log
--En este caso muestra LOG_BACKUP, este dato es informativo
SELECT name, log_reuse_wait_desc FROM sys.databases;
GO

--Ejecutamos un backup de LOG
BACKUP LOG PruebaLog TO DISK = 'E:\bdTest\PruebaLog_tr.bak'
WITH INIT;
GO

--Volvemos a examinar el archivo de Log
--Nótese que se ha liberado espacio, es decir, el log se ha truncado
SELECT name AS Archivo,
       size * 8 /1024. AS MB,  
       FILEPROPERTY(name,'SpaceUsed') * 8 /1024. AS MBUsado,
       CAST(FILEPROPERTY(name,'SpaceUsed') AS decimal(10,4))
         / CAST(size AS decimal(10,4)) * 100 AS PctUsado	
FROM sys.database_files
WHERE type = 1;	
GO	

