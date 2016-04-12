USE [Lime_prod]
GO
/****** Object:  StoredProcedure [dbo].[csp_deleteLicenses_coworker]    Script Date: 03/22/2016 10:22:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[csp_deleteLicenses_coworker]
AS
BEGIN
	update licenses_coworker 
	set [status] = 2 
	,[timestamp] = getdate()
	where [status] = 0 
	and createdtime < dateadd(yyyy,-1,getdate())	
END
