SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [hq].[tvf_Core_Split_CamelCase]
(
   @String NVARCHAR(MAX)
)
RETURNS TABLE
RETURN
(
	WITH Start(i) AS (
		SELECT S.i 
		FROM hq.tvf_Core_Rows(DATALENGTH(@String) / 2) S
		WHERE 
			S.i = 1
			OR (
				SUBSTRING(@String, S.i, 1) LIKE '[a-z]'
				AND SUBSTRING(@String, S.i, 1) = UPPER(SUBSTRING(@String, S.i, 1)) COLLATE Latin1_General_CS_AS
			)
	)
	SELECT
		i = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), 
		Item = SUBSTRING(@String, S.i, ISNULL(E.i, DATALENGTH(@String) / 2 + 1) - S.i)
	FROM 
		Start S
		OUTER APPLY (SELECT TOP 1 i FROM Start WHERE i > S.i) E
)

GO
