SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [hq].[v_Recon_Break]

AS

SELECT
	B.RowKey,
	M.LeftObjSchema,
	M.LeftObjName,
	M.LeftColName,
	LD.DataType AS LeftDataType,
	B.LeftValue,
	B.LeftRowExists,
	M.RightObjSchema,
	M.RightObjName,
	M.RightColName,
	RD.DataType AS RightDataType,
	B.RightValue,
	B.RightRowExists
FROM
	hq.t_Recon_Break B
	INNER JOIN hq.t_Recon_Map M ON M.MapId = B.MapId
	INNER JOIN INFORMATION_SCHEMA.COLUMNS LC ON
		LC.TABLE_SCHEMA = M.LeftObjSchema
		AND LC.TABLE_NAME = M.LeftObjName
		AND LC.COLUMN_NAME = M.LeftColName
	CROSS APPLY hq.tvf_Core_ComposeDatatype(LC.DATA_TYPE, LC.CHARACTER_MAXIMUM_LENGTH, LC.NUMERIC_PRECISION, LC.NUMERIC_SCALE) LD
	INNER JOIN INFORMATION_SCHEMA.COLUMNS RC ON
		RC.TABLE_SCHEMA = M.RightObjSchema
		AND RC.TABLE_NAME = M.RightObjName
		AND RC.COLUMN_NAME = M.RightColName
	CROSS APPLY hq.tvf_Core_ComposeDatatype(RC.DATA_TYPE, RC.CHARACTER_MAXIMUM_LENGTH, RC.NUMERIC_PRECISION, RC.NUMERIC_SCALE) RD
	





GO
