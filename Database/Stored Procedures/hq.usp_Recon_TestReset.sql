SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [hq].[usp_Recon_TestReset] 
AS
BEGIN
	TRUNCATE TABLE hq.t_Recon_Map

	SET IDENTITY_INSERT hq.t_Recon_Map ON

	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (1, 'hq', 't_Recon_TestLeft', 'LeftKey1', 'hq', 't_Recon_TestRight', 'RightKey1', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (2, 'hq', 't_Recon_TestLeft', 'LeftKey2', 'hq', 't_Recon_TestRight', 'RightKey2', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (3, 'hq', 't_Recon_TestLeft', 'LeftCol1Bit', 'hq', 't_Recon_TestRight', 'RightCol1Bit', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (4, 'hq', 't_Recon_TestLeft', 'LeftCol2Int', 'hq', 't_Recon_TestRight', 'RightCol2Int', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (5, 'hq', 't_Recon_TestLeft', 'LeftCol3Date', 'hq', 't_Recon_TestRight', 'RightCol3Date', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (6, 'hq', 't_Recon_TestLeft', 'LeftCol4Decimal', 'hq', 't_Recon_TestRight', 'RightCol4Decimal', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (7, 'hq', 't_Recon_TestLeft', 'LeftCol5Numeric', 'hq', 't_Recon_TestRight', 'RightCol5Numeric', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (8, 'hq', 't_Recon_TestLeft', 'LeftCol6Nvarchar', 'hq', 't_Recon_TestRight', 'RightCol6Nvarchar', 1)
	INSERT hq.t_Recon_Map (MapId, LeftObjSchema, LeftObjName, LeftColName, RightObjSchema, RightObjName, RightColName, Reconcile) VALUES (9, 'hq', 't_Recon_TestLeft', 'LeftCol7NoReconcile', 'hq', 't_Recon_TestRight', 'RightCol7NoReconcile', 0)

	SET IDENTITY_INSERT hq.t_Recon_Map OFF

	DECLARE @ErrorPer int = 100

	TRUNCATE TABLE hq.t_Recon_TestLeft
	INSERT hq.t_Recon_TestLeft
	EXEC hq.usp_Recon_TestGenerate @Rows = 100

	TRUNCATE TABLE hq.t_Recon_TestRight
	INSERT hq.t_Recon_TestRight
	EXEC hq.usp_Recon_TestGenerate @Rows = 101

	UPDATE R
	SET
		R.RightCol1Bit = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol1Bit ELSE L.LeftCol1Bit END,
		R.RightCol2Int = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol2Int ELSE L.LeftCol2Int END,
		R.RightCol3Date = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol3Date ELSE CONVERT(nvarchar(MAX), L.LeftCol3Date, 121) END,
		R.RightCol4Decimal = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol4Decimal ELSE L.LeftCol4Decimal END,
		R.RightCol5Numeric = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol5Numeric ELSE L.LeftCol5Numeric END,
		R.RightCol6Nvarchar = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol6Nvarchar ELSE L.LeftCol6Nvarchar END,
		R.RightCol7NoReconcile = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol7NoReconcile ELSE L.LeftCol7NoReconcile END,
		R.RightCol8NoMapping = CASE WHEN ABS(CHECKSUM(NEWID()) % @ErrorPer) = 0 THEN R.RightCol8NoMapping ELSE L.LeftCol8NoMapping END
	FROM
		hq.t_Recon_TestLeft L
		INNER JOIN hq.t_Recon_TestRight R ON R.RightKey1 = L.LeftKey1 AND R.RightKey2 = L.LeftKey2
END
GO
