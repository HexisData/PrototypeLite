SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [hq].[usp_Core_PrintTrace] 
	-- Add the parameters for the stored procedure here
    @Msg nvarchar(MAX),
    @MsgLen int = 30,
    @TimeLen int = 10,
    @TraceStart datetime OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TimeStr nvarchar(MAX) = CAST(DATEDIFF(ms, @TraceStart, GETDATE())
        / 1000.0 AS decimal(38, 3));

    SET @Msg = LEFT(@Msg + REPLICATE('.', @MsgLen), @MsgLen) + REPLICATE(' ', @TimeLen - LEN(@TimeStr)) + @TimeStr + 's';
    RAISERROR(@Msg, 0, 1) WITH NOWAIT;

    SET @TraceStart = GETDATE();
END;

GO
