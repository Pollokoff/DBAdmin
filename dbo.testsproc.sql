SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[testsproc]
as
	PRINT 'start'

	select 1 

	PRINT 'step 1'

--	select 2

	RAISERROR('test',15,1) --WITH NOWAIT
	PRINT @@Error

	PRINT 'step 2'

	PRINT 'end'
GO
