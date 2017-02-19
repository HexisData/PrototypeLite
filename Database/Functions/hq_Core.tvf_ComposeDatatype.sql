SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [hq_Core].[tvf_ComposeDatatype] 
(	
	@DATA_TYPE nvarchar(128), 
	@CHARACTER_MAXIMUM_LENGTH int,
	@NUMERIC_PRECISION tinyint,
	@NUMERIC_SCALE int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT @DATA_TYPE + CASE 
		WHEN @DATA_TYPE LIKE '%char' THEN '(' + CASE @CHARACTER_MAXIMUM_LENGTH WHEN -1 THEN 'max' ELSE CAST(@CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(128)) END + ')'
		WHEN @DATA_TYPE IN ('decimal', 'numeric') THEN '(' + CAST(@NUMERIC_PRECISION AS NVARCHAR(128)) + ',' + CAST(@NUMERIC_SCALE AS NVARCHAR(128)) + ')'
		ELSE ''
	END AS DataType

)
GO
