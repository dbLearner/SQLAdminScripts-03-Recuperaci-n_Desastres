--------------------------------------------------------------------------------- 
--Copias de seguridad del último mes
--------------------------------------------------------------------------------- 
SELECT DISTINCT
   RTRIM(CONVERT(CHAR(100), SERVERPROPERTY('Servername'))) AS [Instancia], 
   s.database_name AS [Base Datos],  
   s.backup_start_date AS [Inicio],  
   s.backup_finish_date AS [Fin], 
   CAST(s.backup_finish_date-s.backup_start_date AS TIME) AS [Tiempo],
   --msdb.dbo.backupset.expiration_date AS [Fecha expiración], 
   CASE s.type   
	 WHEN 'D' THEN 'D - Full'
     WHEN 'I' THEN 'I - Diferencial'
     WHEN 'L' THEN 'L - Log'
     WHEN 'F' THEN 'F - Archivo/Grupo archivo'
     WHEN 'G' THEN 'G - Archivo diferencial'
     WHEN 'P' THEN 'P - Parcial'
     WHEN 'Q' THEN 'Q - Parcial diferencial'
   END AS [Tipo], 
   CASE s.is_copy_only
	   WHEN 1 THEN 'Si'
	   ELSE 'No'
   END [Solo copia?],
   --msdb.dbo.backupset.backup_size/1024/1024 AS [Tamaño MB],  
   s.backup_size/1024.0/1024.0/1024.0 AS [Tamaño GB],  
   ISNULL(mf.logical_device_name,'') AS [Dispositivo lógico],  
   mf.physical_device_name AS [Archivo físico], 
   LEFT(mf.physical_device_name,2) AS [Unidad],   
   s.name AS [Backup set], 
   ISNULL(s.description,'') AS [Descripción]
FROM   msdb.dbo.backupmediafamily  mf
   INNER JOIN msdb.dbo.backupset s
     ON mf.media_set_id = s.media_set_id  
WHERE  (CONVERT(datetime, s.backup_start_date, 102) >= GETDATE() - 30)  
--AND s.database_name = 'master'
ORDER BY  
   s.database_name, 
   s.backup_finish_date 


------------------------------------------------------------------------------------------- 
--Copia de seguridad full más reciente para cada base de datos
------------------------------------------------------------------------------------------- 
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Instancia], 
   database_name AS [Base datos],  
   MAX(backup_finish_date) AS [Última copia Full] 
FROM  msdb.dbo.backupset
WHERE  type = 'D'
GROUP BY database_name  
ORDER BY [Última copia Full] DESC 

------------------------------------------------------------------------------------------- 
--Copia de seguridad full más reciente para cada base de datos - Detalado
------------------------------------------------------------------------------------------- 
SELECT  
   s.Instancia,  
   s.[Última copia Full],  
   mfs.Inicio,  
   mfs.[Fecha Expiración], 
   mfs.[Tamaño GB],  
   mfs.[Dispositivo lógico],  
   mfs.[Archivo físico],   
   mfs.Nombre, 
   mfs.Descripción 
FROM 
   (SELECT  
		CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Instancia], 
		database_name AS [Base datos],  
		MAX(backup_finish_date) AS [Última copia Full] 
	FROM  msdb.dbo.backupset
	WHERE  type = 'D'
	GROUP BY database_name  ) AS s 
    
   LEFT JOIN  

   (SELECT   
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Instancia], 
   s.database_name AS [Base Datos],  
   s.backup_start_date AS [Inicio],  
   s.backup_finish_date AS [Fin], 
   s.expiration_date AS [Fecha Expiración], 
   s.backup_size/1024/1024 AS [Tamaño GB],  
   mf.logical_device_name AS [Dispositivo lógico],  
   mf.physical_device_name AS [Archivo físico],   
   s.name AS [Nombre], 
   s.[description] AS [Descripción]
   FROM msdb.dbo.backupmediafamily mf
    INNER JOIN msdb.dbo.backupset s
	 ON mf.media_set_id = s.media_set_id  
   WHERE  s.type = 'D') AS mfs 
     ON s.Instancia = mfs.Instancia AND s.[Base datos] = mfs.[Base Datos] AND s.[Última copia Full] = mfs.Fin
   ORDER BY s.[Última copia Full] DESC