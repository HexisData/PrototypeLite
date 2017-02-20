SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Recon_TestGenerate] 
	@Rows int = 1000
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CONVERT(nvarchar(MAX), DATEADD(d, R.i / 10, CAST(CAST(GETDATE() AS date) AS datetime)), 121) AS Key1,
		(R.i - 1) % 10 + 1 AS Key2,
		ABS(CHECKSUM(NEWID()) % 2) AS Col1Bit,
		ABS(CHECKSUM(NEWID()) % 1000) AS Col2Int,
		CONVERT(nvarchar(MAX), DATEADD(d, ABS(CHECKSUM(NEWID()) % 30), CAST(CAST(GETDATE() AS date) AS datetime)), 121) AS Col3Date,
		CAST(ABS(CHECKSUM(NEWID()) % 1000000000) AS decimal(38,8)) / 10000 AS Col4Decimal,
		CAST(ABS(CHECKSUM(NEWID()) % 1000000000) AS decimal(38,8)) / 10000 AS Col5Numeric,
		LEFT(NEWID(), 8) AS Col6Nvarchar,
		LEFT(NEWID(), 8) AS Col7NoReconcile,
		LEFT(NEWID(), 8) AS Col8NoMapping
	FROM
		hq.tvf_Core_Rows(@Rows) R
END

GO
