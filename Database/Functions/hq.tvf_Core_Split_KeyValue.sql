SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[tvf_Core_Split_KeyValue] (
	@String NVARCHAR(max),
	@RowDelimiter NVARCHAR(max),
	@ColDelimiter NVARCHAR(255)
	)
RETURNS TABLE

RETURN (
		WITH P AS (
				SELECT R.i AS ir,
					C.i AS ic,
					C.Item
				FROM dbo.tvf_Core_Split_Delimiter(@String, @RowDelimiter) R
				CROSS APPLY dbo.tvf_Core_Split_Delimiter(R.Item, @ColDelimiter) C
				)
		SELECT ir,
			MAX(CASE 
					WHEN ic = 1
						THEN Item
					ELSE NULL
					END) AS RowKey,
			MAX(CASE 
					WHEN ic = 2
						THEN Item
					ELSE NULL
					END) AS RowValue
		FROM P
		GROUP BY ir
		)

GO
