USE master
Go

--Creamos una base de datos de prueba
CREATE DATABASE DemoBackup
GO

USE DemoBackup
GO

--Creamos una tabla de prueba
CREATE TABLE DemoBackup (
Num INT IDENTITY, [DES] FLOAT)

--Insertamos Tres Registros
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
GO
SELECT * FROM DemoBackup
GO

--Primer Backup Full
BACKUP DATABASE DemoBackup TO DISK = 'c:\Backups\DemoFull.bak' 
WITH INIT
GO

--Insertamos Tres Registros más
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
GO
SELECT * FROM DemoBackup
GO

--Backup Log de Transacciones
BACKUP LOG DemoBackup TO DISK = 'c:\Backups\DemoLog.bak' 
WITH INIT
GO

--Insertamos Tres Registros más
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
INSERT INTO DemoBackup ([Des]) VALUES (Rand())
GO
SELECT * FROM DemoBackup
GO

--Forzar Error en la BD bajando el servicio y cambiando de nombre al archivo
USE master 
GO

--Backup del tail log
BACKUP LOG DemoBackup 
TO DISK = 'D:\SQLData\DemoTail.trn' 
WITH INIT, CONTINUE_AFTER_ERROR

--recuperar la base de datos
--Full sin recuperar
RESTORE DATABASE DemoBackup 
FROM DISK = 'D:\SQLData\Demofull.bak'
WITH NORECOVERY, REPLACE

--Log sin recuperar
RESTORE LOG DemoBackup 
FROM DISK = 'D:\SQLData\DemoLog.trn'
WITH NORECOVERY

--Tail Log sin recuperar
RESTORE LOG DemoBackup 
FROM DISK = 'D:\SQLData\DemoTail.trn'
WITH NORECOVERY

Use DemoBackup
GO

SELECT * FROM DemoBackup
GO

--Si me equivoque al final con el recovery
RESTORE DATABASE DemoBackup 
WITH RECOVERY
GO

--
USE master 
GO

DROP DATABASE DemoBackup
GO