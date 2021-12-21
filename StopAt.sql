USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'bdStopAtTest')
	DROP DATABASE bdStopAtTest;
GO
	
CREATE DATABASE bdStopAtTest ON  PRIMARY 
( NAME = 'bdStopAtTest', 
  FILENAME = 'E:\bdTest\bdStopAtTest.mdf' , 
  SIZE = 10240KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = 'bdStopAtTest_log', 
  FILENAME = 'E:\bdTest\bdStopAtTest_log.ldf' , 
  SIZE = 5120KB , FILEGROWTH = 10%);
GO

-- modelo de recuperación completo (FULL)
ALTER DATABASE bdStopAtTest SET RECOVERY FULL;
GO

-- full backup. 
BACKUP DATABASE bdStopAtTest
  TO DISK = 'E:\bdTest\bdStopAtTest_full.bak'
  WITH INIT;
GO

-- tabla de prueba e ingreso de datos
USE bdStopAtTest;
GO

SET NOCOUNT ON;

CREATE TABLE StopAtTest
( TestId int IDENTITY(1,1) PRIMARY KEY,
  ColTest1 char(500),
  ColTest2 bigint,
  Fecha datetime
);
GO

-- Insertamos un registro
INSERT INTO StopAtTest (ColTest1,ColTest2,Fecha)
VALUES('registro de prueba 1',1,SYSDATETIME());
GO

-- Transacción con marca
BEGIN TRAN MarcaDeInsersion WITH MARK 'Transaccion de seguimiento'
  INSERT INTO StopAtTest (ColTest1,ColTest2,Fecha)
    VALUES('registro de prueba 2-primera transacción marcada',2, SYSDATETIME());
COMMIT TRAN PriorToInsert;
GO

-- insertamos un registro
INSERT INTO StopAtTest (ColTest1,ColTest2,Fecha)
VALUES('registro de prueba 3',3, SYSDATETIME());
GO

-- Transacción con marca
BEGIN TRAN MarcaDeInsersion WITH MARK 'Transaccion de seguimiento'
  INSERT INTO StopAtTest (ColTest1,ColTest2,Fecha)
    VALUES('registro de prueba 4-segunda transacción marcada',4, SYSDATETIME());
COMMIT TRAN PriorToInsert;
GO

SELECT * FROM StopAtTest;
GO
 
-- log backup
USE master;
GO

BACKUP LOG bdStopAtTest
  TO DISK = 'E:\bdTest\bdStopAtTest.tr'
  WITH INIT;
GO

-- Restauramos toda la base de datos
USE master;
GO

RESTORE DATABASE bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest_full.bak'
  WITH REPLACE, NORECOVERY;
GO

RESTORE LOG bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest.tr'
  WITH RECOVERY;
GO

USE bdStopAtTest;
GO

SELECT * FROM dbo.StopAtTest;
GO
	
-- Restauramos utilizando las marcas para STOPATMARK
USE master;
GO

RESTORE DATABASE bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest_full.bak'
  WITH REPLACE, NORECOVERY;
GO

RESTORE LOG bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest.tr'
  WITH RECOVERY, STOPATMARK = 'MarcaDeInsersion';
GO

USE bdStopAtTest;
GO

SELECT * FROM dbo.StopAtTest;
GO
	
-- Restauramos utilizando las marcas para STOPBEFOREMARK master;
USE master
GO

RESTORE DATABASE bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest_full.bak'
  WITH REPLACE, NORECOVERY;
GO

RESTORE LOG bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest.tr'
  WITH RECOVERY, STOPBEFOREMARK = 'MarcaDeInsersion';
GO

USE bdStopAtTest;
GO

SELECT * FROM dbo.StopAtTest;
GO

-- Restauramos utilizando la fecha y hora
USE master
GO

RESTORE DATABASE bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest_full.bak'
  WITH REPLACE, NORECOVERY;
GO

RESTORE LOG bdStopAtTest
  FROM DISK = 'E:\bdTest\bdStopAtTest.tr'
  WITH RECOVERY, STOPAT = '2012-02-07 18:59:07';
GO

USE bdStopAtTest;
GO

SELECT * FROM dbo.StopAtTest;
GO