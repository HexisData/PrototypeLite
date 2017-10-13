SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [hq].[tvf_Core_Split_DbObjName]
(
   @String NVARCHAR(MAX)
)
RETURNS TABLE
RETURN
(
	SELECT
		COALESCE(C.Item, D.Item) AS Item
	FROM
		hq.tvf_Core_Split_Delimiter(@String, '_') D
		OUTER APPLY (
			SELECT Item 
			FROM hq.tvf_Core_Split_CamelCase(D.Item)
			WHERE D.Item <> UPPER(D.Item) COLLATE Latin1_General_CS_AS
		) C
)

GO
