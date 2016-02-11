USE [lime_core_v5_1_mfa]
GO
/****** Object:  StoredProcedure [dbo].[csp_getHelpdeskStatistics]    Script Date: 2015-06-23 16:25:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<SSM>
-- Create date: <11/11/2013>
-- Description:	<returns helpdeskl statics in XMl>
-- =============================================
ALTER PROCEDURE [dbo].[csp_getHelpdeskStatistics]
	@@idcoworker INT
	
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	
	SET DATEFIRST 1

	--DECLARE @@idcoworker INT 
	--SET @@idcoworker = 1001
	
	DECLARE @section INT
	
	SET @section = (select section from coworker where idcoworker = @@idcoworker)

	SELECT
		--statics for general helpdesk tickets
		(
		SELECT SUM([open]) AS 'open', SUM([notInitiated]) As 'notInitiated', SUM([delayed]) as 'delayed' FROM 
		(
			SELECT
				SUM(1)AS 'open'
				, 0  AS 'notInitiated'
				,SUM(CASE WHEN [deadlinedate] < GETDATE() THEN 1 ELSE 0 END) AS 'delayed'            
			FROM helpdesk WITH (NOLOCK)
			where [status]=0 
			AND [enddate] is NULL
			UNION ALL
			SELECT 
				0 As 'open',
				COUNT(DISTINCT helpdesk) as 'notInitiated',
				0 as 'delayed'
			from helpdesk_section  WITH (NOLOCK)
			where [coworker] is null 
			AND [endtime] IS NULL 
			and [status] = 0
		) as a
		FOR XML RAW('value'),TYPE, ROOT('general')
		),
		
		--statics for coworker helpdesk tickets
		(SELECT 
			SUM(1)  AS 'open'
			,SUM(CASE WHEN [coworker] IS NULL THEN 1 ELSE 0 END) as 'notInitiated'
			,SUM(CASE WHEN [deadlinedate] < GETDATE() THEN 1 ELSE 0 END) as 'delayed'
		FROM [helpdesk_section] WITH (NOLOCK)
		WHERE [status] = 0
		AND [endtime] IS NULL
		AND [section] = @section
		FOR XML RAW('value'),TYPE, ROOT('coworker')	
		),
		
		--statics for incomming helpdesk tickets
		(SELECT 
			SUM(CASE WHEN CONVERT(DATE, [createdtime]) = CONVERT(DATE, GETDATE()) THEN 1 ELSE 0 END) AS 'today'
			,SUM(CASE WHEN DATEPART(YEAR, [createdtime]) = DATEPART(yy, GETDATE()) AND DATEPART(ww, [createdtime]) = DATEPART(ww, GETDATE()) THEN 1 ELSE 0 END) AS 'week'
			,SUM(CASE WHEN DATEPART(YEAR, [createdtime]) = DATEPART(yy, GETDATE()) AND DATEPART(mm, [createdtime]) = DATEPART(mm, GETDATE()) THEN 1 ELSE 0 END) AS 'month'
	            
		FROM [helpdesk] WITH (NOLOCK)
		WHERE [status] = 0
		AND [createdtime] > DATEADD(MONTH, -1, GETDATE())
		FOR XML RAW('value'),TYPE, ROOT('incomming')	
		),
		
		--statics for closed helpdesk tickets
		(SELECT 
			SUM(CASE WHEN CONVERT(DATE, [enddate]) = CONVERT(DATE, GETDATE()) THEN 1 ELSE 0 END) AS 'today'
			,SUM(CASE WHEN DATEPART(YEAR, [enddate]) = DATEPART(yy, GETDATE()) AND DATEPART(ww, [enddate]) = DATEPART(ww, GETDATE()) THEN 1 ELSE 0 END) AS 'week'
			,SUM(CASE WHEN DATEPART(YEAR, [enddate]) = DATEPART(yy, GETDATE()) AND DATEPART(mm, [enddate]) = DATEPART(mm, GETDATE()) THEN 1 ELSE 0 END) AS 'month'     
		FROM [helpdesk] WITH (NOLOCK)
		WHERE [status] = 0
		AND [enddate] > DATEADD(MONTH, -1, GETDATE())
		FOR XML RAW('value'),TYPE, ROOT('closed')
	)
	FOR XML PATH(''), TYPE, ROOT ('helpdeskstatics');	
		
	
END