/*
----------------------------------------------------------------------------------------------------------------------
PROPOSITO            | RESTORE CON QUERY DINAMICO PARA LOS DIFERENTES PARAMETROS DE EJECUCIÓN
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE ENTRADA| No Aplica
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE SALIDA | No Aplica
----------------------------------------------------------------------------------------------------------------------
CREADO POR           | Alberto De Rossi Tonussi (http://dblearner.com)
FECHA CREACION       | 03/09/2014
----------------------------------------------------------------------------------------------------------------------
HISTORIAL DE CAMBIOS | FECHA      RESPONSABLE         MOTIVO
                     | ---------- ------------------- ----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
PRUEBA:              
  No Aplica
----------------------------------------------------------------------------------------------------------------------
*/
USE master
GO
-----------------------------------------------------------------------------------------------
DECLARE 
@BaseDatos varchar(255) = 'dbDBLAop',--INDICAR EN ESTA VARIABLE LA BASE DE DATOS A RESPALDAR
-----------------------------------------------------------------------------------------------
@RutaRestore varchar(255) = 'E:\SQL Backups\', --INDICAR EN ESTA VARIABLE LA RUTA (INCLUIR \ AL FINAL)
-----------------------------------------------------------------------------------------------
@ArchivoBackup VARCHAR(255) = 'dbDBLAop_LOG_20190720_102238.trn',--VARIABLE PARA NOMBRE DEL ARCHIVO DE BACKUP A RESTAURAR
-----------------------------------------------------------------------------------------------
@Comando nvarchar(1000),      --VARIABLE PARA LA EJECUCIÓN DEL BACKUP
@FlagRecovery bit = 1         --VARIABLE PARA TIPO DE RESTORE 1=RECOVERY / 0=NORECOVERY
-----------------------------------------------------------------------------------------------
--PONER LA BASE DE DATOS EN MODO RESTEICTIVO PARA DESCONECTAR A TODOS LOS USUARIO
SET @Comando = N'ALTER DATABASE '+@BaseDatos+' SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
--EJECUCION DE QUERY DINAMICO
--EXECUTE sys.sp_executesql @command1=@Comando
-----------------------------------------------------------------------------------------------
--DEFINICION DE QUERY DINAMICO PARA EJECUCION DEL RESTORE
SET @Comando = N'RESTORE DATABASE '+@BaseDatos 
SET @Comando = @Comando + ' FROM DISK = '''+@RutaRestore+@ArchivoBackup+'''' 
IF @FlagRecovery = 1
  SET @Comando = @Comando + ' WITH FILE=1, REPLACE, CHECKSUM, STATS = 10'
ELSE
  SET @Comando = @Comando + ' WITH NORECOVERY, FILE=1, REPLACE, CHECKSUM, STATS = 10'

PRINT @Comando --(VERIFICACION DE VARIABLE)
-----------------------------------------------------------------------------------------------
--EJECUCION DE QUERY DINAMICO DE RESTORE
EXECUTE sys.sp_executesql @command1=@Comando
-----------------------------------------------------------------------------------------------
--PONER LA BASE DE DATOS EN MODO RESTRICTIVO PARA DESCONECTAR A TODOS LOS USUARIO
SET @Comando = N'ALTER DATABASE '+@BaseDatos+' SET MULTI_USER'
--EJECUCION DE QUERY DINAMICO
--EXECUTE sys.sp_executesql @command1=@Comando

SELECT 
restore_date,
destination_database_name, 
CASE restore_type
	 WHEN 'D' THEN 'D - Full'
     WHEN 'I' THEN 'I - Diferencial'
     WHEN 'L' THEN 'L - Log'
     WHEN 'F' THEN 'F - Archivo/Grupo archivo'
     WHEN 'G' THEN 'G - Archivo diferencial'
     WHEN 'P' THEN 'P - Parcial'
     WHEN 'Q' THEN 'Q - Parcial diferencial' 
END TipoRestore
FROM msdb.dbo.restorehistory
ORDER BY restore_date DESC
GO

