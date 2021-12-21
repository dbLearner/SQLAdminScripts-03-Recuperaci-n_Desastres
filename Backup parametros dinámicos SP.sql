/*
----------------------------------------------------------------------------------------------------------------------
PROPOSITO            | BACKUP CON QUERY DINAMICO PARA LOS DIFERENTES PARAMETROS DE EJECUCIÓN
                     | SE PUEDE UTILIZAR PARA EJECUTAR CUALQUIER TIPO DE BACKUP
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE ENTRADA| @TipoBackup FULL, DIFF, LOG
                     | @BaseDatos nombre d la BD a respaldar
                     | @RutaBackup ruta donde se guardará la copia de seguridad
                     | @FlagValidación para mostrar el resultado del backup
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
  EXEC master.dbo.uspBackup 'FULL', 'msdb', 'E:\SQL Backups\', 1
----------------------------------------------------------------------------------------------------------------------
*/
USE master
GO

ALTER PROCEDURE dbo.uspBackup
@TipoBackup varchar(4) = 'FULL', --Variable para tipo backup, puede ser FULL, DIFF o log
-----------------------------------------------------------------------------------------------
@BaseDatos varchar(255) = '<base de datos>', --INDICAR EN ESTA VARIABLE LA BASE DE DATOS A RESPALDAR
-----------------------------------------------------------------------------------------------
@RutaBackup varchar(255) = '<ruta donde guardar el backup>', --INDICAR EN ESTA VARIABLE LA RUTA (INCLUIR \ AL FINAL)
-----------------------------------------------------------------------------------------------
@FlagValidación bit = 1 --Flag de ejecución de consulta final de validación (se desactiva en los job)
AS
SET NOCOUNT ON
DECLARE @EjecucionBackup VARCHAR(17), --VARIABLE PARA FECHA Y HORA DE EJECUCION BACKUP
@Comando nvarchar(1000)       --VARIABLE PARA LA EJECUCION DEL BACKUP
-----------------------------------------------------------------------------------------------
--DEFINIMOS LA FECHA DE EJECUCION - AAAMMMDDD
SET @EjecucionBackup=CONCAT(DATEPART(YY, GETDATE()), 
    RIGHT(CONCAT('0',DATEPART(MM, GETDATE())),2), 
    RIGHT(CONCAT('0',DATEPART(DD, GETDATE())),2))
--DEFINIMOS LA HORA DE EJECUCION Y LA UNIMOS A LA FECHA - AAAMMDD_HHMISS
SET @EjecucionBackup=CONCAT(@EjecucionBackup, '_', 
   RIGHT(CONCAT('0',DATEPART(HH, GETDATE())),2),
   RIGHT(CONCAT('0',DATEPART(MI, GETDATE())),2),
   RIGHT(CONCAT('0',DATEPART(SS, GETDATE())),2))
--PRINT @EjecucionBackup --(VERIFICACION DE VARIABLE)
-----------------------------------------------------------------------------------------------
--DEFINICION DE QUERY DINAMICO PARA EJECUCION DE BACKUP
IF @TipoBackup = 'LOG'
  SET @Comando = N'BACKUP LOG '+@BaseDatos 
ELSE
  SET @Comando = N'BACKUP DATABASE '+@BaseDatos 

IF @TipoBackup = 'FULL'
  SET @Comando = @Comando + N' TO DISK = '''+@RutaBackup+@BaseDatos+N' '+@EjecucionBackup+N'_FULL.bak''' 
ELSE
  IF @TipoBackup = 'DIFF'
    SET @Comando = @Comando + N' TO DISK = '''+@RutaBackup+@BaseDatos+N' '+@EjecucionBackup+N'_DIFF.bak''' 
  ELSE
    SET @Comando = @Comando + N' TO DISK = '''+@RutaBackup+@BaseDatos+N' '+@EjecucionBackup+N'_LOG.trn''' 

IF @TipoBackup = 'FULL' OR @TipoBackup = 'LOG' 
  SET @Comando = @Comando + N' WITH INIT, COMPRESSION, CHECKSUM, STATS = 10'
ELSE
  SET @Comando = @Comando + N' WITH DIFFERENTIAL, INIT, COMPRESSION, CHECKSUM, STATS = 10'

PRINT @Comando --(VERIFICACION DE VARIABLE)
-----------------------------------------------------------------------------------------------
--EJECUCION DE QUERY DINAMICO
EXECUTE sys.sp_executesql @command1=@Comando
-----------------------------------------------------------------------------------------------
--CONSULTA DE VALIDACIÓN (ULTIMOS 5 BACKUPS DE LA BASE DE DATOS)
--SOLO SE EJECUTA SI EL FLAG ESTÁ ACTIVO, PARA DESACTIVARLO EN LOS JOB
IF @FlagValidación = 1
	SELECT TOP 5 --DISTINCT
	   RTRIM(CONVERT(CHAR(100), SERVERPROPERTY('Servername'))) AS Instancia, 
	   s.database_name AS BaseDatos,  
	   s.backup_start_date AS Inicio,  
	   s.backup_finish_date AS Fin, 
	   CAST(s.backup_finish_date-s.backup_start_date AS TIME) AS Tiempo,
	   --msdb.dbo.backupset.expiration_date AS Fecha expiración, 
	   CASE s.type   
		 WHEN 'D' THEN 'D - Full'
		 WHEN 'I' THEN 'I - Diferencial'
		 WHEN 'L' THEN 'L - Log'
		 WHEN 'F' THEN 'F - Archivo/Grupo archivo'
		 WHEN 'G' THEN 'G - Archivo diferencial'
		 WHEN 'P' THEN 'P - Parcial'
		 WHEN 'Q' THEN 'Q - Parcial diferencial'
	   END AS Tipo, 
	   CASE s.is_copy_only
		   WHEN 1 THEN 'Si'
		   ELSE 'No'
	   END SoloCopia,
	   --msdb.dbo.backupset.backup_size/1024/1024 AS Tamaño MB,  
	   s.backup_size/1024.0/1024.0 AS TamañoMB,  
	   mf.physical_device_name AS ArchivoFisico, 
	   LEFT(mf.physical_device_name,2) AS Unidad
	FROM   msdb.dbo.backupmediafamily  mf
	   INNER JOIN msdb.dbo.backupset s
		 ON mf.media_set_id = s.media_set_id  
	WHERE  (CONVERT(datetime, s.backup_start_date, 102) >= GETDATE() - 30)  
	       AND s.database_name = @BaseDatos
	ORDER BY  
	   s.database_name, 
	   s.backup_finish_date DESC

SET NOCOUNT OFF
GO