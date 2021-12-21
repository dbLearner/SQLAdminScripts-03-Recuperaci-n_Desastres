/*
----------------------------------------------------------------------------------------------------------------------
PROPOSITO            | ELIMINA LOS ARCHIVOS DE BACKUP EN BASE A UNA ANTIGUEDAD EN MINUTOS
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE ENTRADA| @RutaBackup ruta donde se guardará la copia de seguridad
                     | @Extension extención del backup (BAK o TRN)
                     | @AntiguedadMin minutos de antiguedad del backup
----------------------------------------------------------------------------------------------------------------------
PARAMETROS DE SALIDA | No Aplica
----------------------------------------------------------------------------------------------------------------------
CREADO POR           | Alberto De Rossi Tonussi (http://dblearner.com)
FECHA CREACION       | 17/08/2016
----------------------------------------------------------------------------------------------------------------------
HISTORIAL DE CAMBIOS | FECHA      RESPONSABLE         MOTIVO
                     | ---------- ------------------- ----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
PRUEBA:              
   EXEC master.dbo.usp_DeleteBackup 'E:\SQL Backups\dbHCENTER2\', 'TRN', 10
----------------------------------------------------------------------------------------------------------------------
*/
USE master
GO

ALTER PROCEDURE dbo.usp_DeleteBackup
    @RutaBackup varchar(256),
	@Extension char(3),
	@AntiguedadMin int
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Fecha NVARCHAR(50)
	DECLARE @FechaHora DATETIME

	SET @FechaHora = DateAdd(n, - @AntiguedadMin, GetDate())

        SET @Fecha = (Select Replace(Convert(nvarchar, @FechaHora, 111), '/', '-') + 'T' + Convert(nvarchar, @FechaHora, 108))

	EXECUTE master.dbo.xp_delete_file 0,
		@RutaBackup,
		@Extension,
		@Fecha,
		1
END
GO


