USE master
GO

--Database Mirror (Solo Enterprise Edition)
BACKUP DATABASE AdventureWorks2008R2
TO DISK = 'D:\BACKUP\AW08Full.bak'
MIRROR TO DISK = '\\PERMS16\BACKUP\BD\AW08Full.bak'
WITH FORMAT, COMPRESSION, CHECKSUM
GO

RESTORE VERIFYONLY FROM DISK = 'D:\BACKUP\AW08Full.bak'

--otra técnica
RESTORE FILELISTONLY FROM DISK = 'D:\BACKUP\AW08Full.bak'

--Restauramos la base de datos en una ubicación de prueba
--se deja la BD en estado de recuperación
RESTORE DATABASE AdventureWorks2008R2_TEST
FROM DISK = 'D:\BACKUP\AW08Full.bak'
WITH 
  MOVE 'AdventureWorks2008R2_Data' TO 'D:\TestData\AdventureWorks2008R2_Data_Test.tmdf',
  MOVE 'AdventureWorks2008R2_Log' TO 'D:\TestData\AdventureWorks2008R2_Log_Test.tldf',
  MOVE 'FileStreamDocuments2008R2' TO 'D:\TestData\FileStreamDocuments2008R2_Test',
NORECOVERY
GO

--Se recupera la base de datos pero en modo de usuario restringido
RESTORE DATABASE AdventureWorks2008R2_TEST 
WITH RECOVERY, RESTRICTED_USER
GO

--Ejecutamos el comando de verificaci[on de base de datos
DBCC CHECKDB(AdventureWorks2008R2_TEST)
GO

--se elimina la base de datos de prueba
DROP DATABASE AdventureWorks2008R2_TEST
GO