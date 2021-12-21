--------------------------------------------------------------------------------- 
--Copias de seguridad del �ltimo mes
--------------------------------------------------------------------------------- 
SELECT DISTINCT
   RTRIM(CONVERT(CHAR(100), SERVERPROPERTY('Servername'))) AS [Instancia], 
   s.database_name AS [Base Datos],  
   s.backup_start_date AS [Inicio],  
   s.backup_finish_date AS [Fin], 
   CAST(s.backup_finish_date-s.backup_start_date AS TIME) AS [Tiempo],
   --msdb.dbo.backupset.expiration_date AS [Fecha expiraci�n], 
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
   --msdb.dbo.backupset.backup_size/1024/1024 AS [Tama�o MB],  
   s.backup_size/1024.0/1024.0/1024.0 AS [Tama�o GB],  
   ISNULL(mf.logical_device_name,'') AS [Dispositivo l�gico],  
   mf.physical_device_name AS [Archivo f�sico], 
   LEFT(mf.physical_device_name,2) AS [Unidad],   
   s.name AS [Backup set], 
   ISNULL(s.description,'') AS [Descripci�n]
FROM   msdb.dbo.backupmediafamily  mf
   INNER JOIN msdb.dbo.backupset s
     ON mf.media_set_id = s.media_set_id  
WHERE  (CONVERT(datetime, s.backup_start_date, 102) >= GETDATE() - 30)  
--AND s.database_name = 'master'
ORDER BY  
   s.database_name, 
   s.backup_finish_date 


------------------------------------------------------------------------------------------- 
--Copia de seguridad full m�s reciente para cada base de datos
------------------------------------------------------------------------------------------- 
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Instancia], 
   database_name AS [Base datos],  
   MAX(backup_finish_date) AS [�ltima copia Full] 
FROM  msdb.dbo.backupset
WHERE  type = 'D'
GROUP BY database_name  
ORDER BY [�ltima copia Full] DESC 

------------------------------------------------------------------------------------------- 
--Copia de seguridad full m�s reciente para cada base de datos - Detalado
------------------------------------------------------------------------------------------- 
SELECT  
   s.Instancia,  
   s.[�ltima copia Full],  
   mfs.Inicio,  
   mfs.[Fecha Expiraci�n], 
   mfs.[Tama�o GB],  
   mfs.[Dispositivo l�gico],  
   mfs.[Archivo f�sico],   
   mfs.Nombre, 
   mfs.Descripci�n 
FROM 
   (SELECT  
		CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Instancia], 
		database_name AS [Base datos],  
		MAX(backup_finish_date) AS [�ltima copia Full] 
	FROM  msdb.dbo.backupset
	WHERE  type = 'D'
	GROUP BY database_name  ) AS s 
    
   LEFT JOIN  

   (SELECT   
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS [Instancia], 
   s.database_name AS [Base Datos],  
   s.backup_start_date AS [Inicio],  
   s.backup_finish_date AS [Fin], 
   s.expiration_date AS [Fecha Expiraci�n], 
   s.backup_size/1024/1024 AS [Tama�o GB],  
   mf.logical_device_name AS [Dispositivo l�gico],  
   mf.physical_device_name AS [Archivo f�sico],   
   s.name AS [Nombre], 
   s.[description] AS [Descripci�n]
   FROM msdb.dbo.backupmediafamily mf
    INNER JOIN msdb.dbo.backupset s
	 ON mf.media_set_id = s.media_set_id  
   WHERE  s.type = 'D') AS mfs 
     ON s.Instancia = mfs.Instancia AND s.[Base datos] = mfs.[Base Datos] AND s.[�ltima copia Full] = mfs.Fin
   ORDER BY s.[�ltima copia Full] DESC