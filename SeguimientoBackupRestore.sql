/*
----------------------------------------------------------------------------------------------------------------------
PROPOSITO            | Seguimento del avance de procesos de BACKUP y RESTORE
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE ENTRADA| No Aplica
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE SALIDA | No Aplica
----------------------------------------------------------------------------------------------------------------------
CREADO POR           | Alberto De Rossi Tonussi (http://dblearner.com)
FECHA CREACION       | 17/04/2015
----------------------------------------------------------------------------------------------------------------------
HISTORIAL DE CAMBIOS | FECHA      RESPONSABLE         MOTIVO
                     | ---------- ------------------- ----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
PRUEBA:              
  No Aplica
----------------------------------------------------------------------------------------------------------------------
*/
SELECT 
  req.session_id AS IDSesion, 
  req.command AS TipoComando, 
  txt.text AS Comando, 
  req.start_time AS HoraInicio, 
  req.percent_complete AS PctAvance, 
  dateadd(second,req.estimated_completion_time/1000, getdate()) as HoraFinEstimada
FROM sys.dm_exec_requests req 
  CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) txt 
WHERE req.command in ('BACKUP DATABASE','RESTORE DATABASE') 