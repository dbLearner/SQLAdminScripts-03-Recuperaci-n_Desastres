USE [master]
GO
CREATE DATABASE [BigFive] ON 
( FILENAME = N'D:\TestData\BigFive.mdf' )
 FOR ATTACH_REBUILD_LOG
GO

drop database [BigFive] 


EXEC sys.sp_attach_single_file_db @dbname='BigFive',@physname='D:\TestData\BigFive.mdf'