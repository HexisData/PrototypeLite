SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [hq_Recon].[usp_Execute] 
	@LeftObjSchema NVARCHAR(128),
	@LeftObjName NVARCHAR(128),
	@RightObjSchema NVARCHAR(128),
	@RightObjName NVARCHAR(128),
	@KeyDelimiter nvarchar(MAX) = '|'
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#ReconCols') IS NOT NULL DROP TABLE #ReconCols

	-- Populate column reference.

	; WITH LC AS (
		SELECT 
			M.MapId,
			C.*
		FROM 
			INFORMATION_SCHEMA.COLUMNS C
			INNER JOIN hq_Recon.t_Map M ON 
				M.LeftObjSchema = C.TABLE_SCHEMA
				AND M.LeftObjName = C.TABLE_NAME
				AND M.LeftColName = C.COLUMN_NAME
		WHERE 
			C.TABLE_SCHEMA = @LeftObjSchema 
			AND C.TABLE_NAME = @LeftObjName
			AND C.DATA_TYPE NOT IN ('image', 'timestamp')
			AND M.Reconcile = 1
	),

	RC AS (
		SELECT 
			M.MapId,
			C.*
		FROM 
			INFORMATION_SCHEMA.COLUMNS C
			INNER JOIN hq_Recon.t_Map M ON 
				M.RightObjSchema = C.TABLE_SCHEMA
				AND M.RightObjName = C.TABLE_NAME
				AND M.RightColName = C.COLUMN_NAME
		WHERE 
			C.TABLE_SCHEMA = @RightObjSchema 
			AND C.TABLE_NAME = @RightObjName
			AND M.Reconcile = 1
	)

	SELECT
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS i,
		LC.MapId,
		CAST(CASE WHEN LCCU.COLUMN_NAME IS NULL AND RCCU.COLUMN_NAME IS NULL THEN 0 ELSE 1 END AS BIT) AS KeyCol, 
		LC.COLUMN_NAME AS LeftColName, 
		LC.DATA_TYPE AS LeftDatatype,
		'CONVERT(nvarchar(max), [' + LC.COLUMN_NAME + ']' + CASE WHEN LC.DATA_TYPE LIKE '%date%' OR LC.DATA_TYPE LIKE '%time%' THEN ', 121' ELSE '' END + ')' AS LeftValueExp,
		RC.COLUMN_NAME AS RightColName,
		LC.DATA_TYPE AS RightDatatype,
		'CONVERT(nvarchar(max), [' + RC.COLUMN_NAME + ']' + CASE WHEN RC.DATA_TYPE LIKE '%date%' OR RC.DATA_TYPE LIKE '%time%' THEN ', 121' ELSE '' END + ')' AS RightValueExp
	INTO #ReconCols
	FROM
		LC
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE LCCU ON 
			LCCU.TABLE_SCHEMA = LC.TABLE_SCHEMA 
			AND LCCU.TABLE_NAME = LC.TABLE_NAME 
			AND LCCU.COLUMN_NAME = LC.COLUMN_NAME
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS LTC ON 
			LTC.CONSTRAINT_SCHEMA = LCCU.CONSTRAINT_SCHEMA
			AND LTC.CONSTRAINT_NAME = LCCU.CONSTRAINT_NAME
			AND LTC.CONSTRAINT_TYPE = 'PRIMARY KEY'
		INNER JOIN RC ON RC.MapId = LC.MapId
		LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE RCCU ON 
			RCCU.TABLE_SCHEMA = RC.TABLE_SCHEMA 
			AND RCCU.TABLE_NAME = RC.TABLE_NAME 
			AND RCCU.COLUMN_NAME = RC.COLUMN_NAME
		LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS RTC ON 
			RTC.CONSTRAINT_SCHEMA = RCCU.CONSTRAINT_SCHEMA
			AND RTC.CONSTRAINT_NAME = RCCU.CONSTRAINT_NAME
			AND RTC.CONSTRAINT_TYPE = 'PRIMARY KEY'

	-- Calculate key expressions. 

	DECLARE 
		@LeftKeyExp nvarchar(MAX) = '',
		@RightKeyExp nvarchar(MAX) = ''

	SELECT
		@LeftKeyExp = @LeftKeyExp + ' + ''' + @KeyDelimiter + ''' + CONVERT(nvarchar(max), [' + C.LeftColName + ']' + CASE WHEN C.LeftDatatype LIKE '%date%' OR C.LeftDatatype LIKE '%time%' THEN ', 121' ELSE '' END + ')',
		@RightKeyExp = @RightKeyExp + ' + ''' + @KeyDelimiter + ''' + CONVERT(nvarchar(max), [' + C.RightColName + ']' + CASE WHEN C.RightDatatype LIKE '%date%' OR C.RightDatatype LIKE '%time%' THEN ', 121' ELSE '' END + ')'
	FROM #ReconCols C
	WHERE KeyCol = 1

	SET @LeftKeyExp = STUFF(@LeftKeyExp, 1, 8 + DATALENGTH(@KeyDelimiter) / 2, '')
	SET @RightKeyExp = STUFF(@RightKeyExp, 1, 8 + DATALENGTH(@KeyDelimiter) / 2, '')

	-- Populate values.
	TRUNCATE TABLE hq_Recon.t_Break

	DECLARE 
		@n int = (SELECT MAX(i) FROM #ReconCols),
		@i int = 3,
		@MapId int,
		@KeyCol bit,
		@LeftValueExp nvarchar(max),
		@RightValueExp nvarchar(max),
		@Sql nvarchar(MAX)

	WHILE @i <= @n
	BEGIN
		SELECT
			@MapId = MapId,
			@KeyCol = KeyCol,
			@LeftValueExp = LeftValueExp,
			@RightValueExp = RightValueExp
		FROM #ReconCols
		WHERE i = @i

		IF @KeyCol = 0
		BEGIN
			SET @Sql = '

	WITH L AS (
		SELECT
			{LeftKeyExp} AS RowKey,
			{MapId} AS MapId,
			{LeftValueExp} AS Value
		FROM
			hq_Recon.t_TestLeft
	),

	R AS (
		SELECT
			{RightKeyExp} AS RowKey,
			{MapId} AS MapId,
			{RightValueExp} AS Value
		FROM
			hq_Recon.t_TestRight
	)

	INSERT hq_Recon.t_Break
	SELECT
		ISNULL(L.RowKey, R.RowKey) AS RowKey,
		ISNULL(L.MapId, R.MapId) AS MapId,
		CASE WHEN L.RowKey IS NULL THEN 0 ELSE 1 END AS LeftRowExists,
		L.Value AS LeftValue,
		CASE WHEN R.RowKey IS NULL THEN 0 ELSE 1 END AS RightRowExists,
		R.Value AS RightValue
	FROM
		L
		FULL JOIN R ON R.RowKey = L.RowKey AND R.MapId = L.MapId
	WHERE 
		L.RowKey IS NULL
		OR R.RowKey IS NULL
		OR L.Value <> R.Value
		OR (L.Value IS NULL AND R.Value IS NOT NULL)
		OR (L.Value IS NOT NULL AND R.Value IS NULL)
	'
			SET @Sql = REPLACE(@Sql, '{MapId}', CONVERT(nvarchar(MAX), @MapId))
			SET @Sql = REPLACE(@Sql, '{LeftKeyExp}', @LeftKeyExp)
			SET @Sql = REPLACE(@Sql, '{LeftValueExp}', @LeftValueExp)
			SET @Sql = REPLACE(@Sql, '{RightKeyExp}', @RightKeyExp)
			SET @Sql = REPLACE(@Sql, '{RightValueExp}', @RightValueExp)

			EXEC sp_executesql @Sql
		END

		SET @i = @i + 1
	END
END
GO
