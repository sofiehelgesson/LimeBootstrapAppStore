USE [gbgapp]
GO
/****** Object:  StoredProcedure [dbo].[csp_get_subscriptions]    Script Date: 2014-05-08 20:45:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_get_subscriptions] 
	-- Add the parameters for the stored procedure here
	@@idcoworker AS INTEGER,
	@@xml AS NVARCHAR(4000) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;
	DECLARE @table TABLE
	(
		idcompany INTEGER,
		idrecord INTEGER,
		[timestamp] DATETIME,
		tablename NVARCHAR(32),
		buttonText NVARCHAR(72)
	)
	INSERT INTO @table
	(idcompany, idrecord,[timestamp], tablename, buttonText)
	(
		SELECT [idcompany], [idhelpdesk], h.[createdtime], N'helpdesk', N'Nytt ärende på ' + c.[name] FROM [subscription] s
		INNER JOIN [company] c ON c.[idcompany] = s.[company] AND c.[status] = 0
		INNER JOIN [helpdesk] h ON h.[company] = c.[idcompany] AND c.[status] = 0
		WHERE s.[status] = 0
		AND s.[coworker] = @@idcoworker and h.[timestamp] > dateadd(day, -7, getdate()) and s.[unsubscribe]=0
		
		UNION ALL
		
		SELECT [idcompany], [idhistory], h.[timestamp], N'history', N'Ny historik på ' + c.[name] FROM [subscription] s
		INNER JOIN [company] c ON c.[idcompany] = s.[company] AND c.[status] = 0
		INNER JOIN [history] h ON h.[company] = c.[idcompany] AND c.[status] = 0
		WHERE s.[status] = 0
		AND s.[coworker] = @@idcoworker and h.[timestamp] > dateadd(day, -7, getdate()) and s.[unsubscribe]=0
	)
	SELECT @@xml = ISNULL((SELECT  * FROM @table AS item ORDER BY [timestamp] DESC FOR XML AUTO), N'')
END
