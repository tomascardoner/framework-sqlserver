SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2018-10-25
-- Description:	Returns a table with elapsed time in years, months and days
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetElapsedYearsMonthsAndDaysFromDatesAsTable') AND type = N'TF')
	DROP FUNCTION dbo.udf_GetElapsedYearsMonthsAndDaysFromDatesAsTable
GO

CREATE FUNCTION udf_GetElapsedYearsMonthsAndDaysFromDatesAsTable
(
	@StartDate date,
	@EndDate date
) RETURNS @ElapsedTime TABLE
	(
	Years smallint null,
	Months smallint null,
	[Days] smallint null
	)
	AS
BEGIN
	DECLARE @FechaTemp datetime
	DECLARE @YearsElapsed smallint
	DECLARE @MonthsElapsed smallint
	DECLARE @DaysElapsed smallint

	SELECT @FechaTemp = @StartDate

	SELECT @YearsElapsed = DATEDIFF(yy, @FechaTemp, @EndDate) - CASE WHEN (MONTH(@StartDate) > MONTH(@EndDate)) OR (MONTH(@StartDate) = MONTH(@EndDate) AND DAY(@StartDate) > DAY(@EndDate)) THEN 1 ELSE 0 END
	SELECT @FechaTemp = DATEADD(yy, @YearsElapsed, @FechaTemp)
	SELECT @MonthsElapsed = DATEDIFF(m, @FechaTemp, @EndDate) - CASE WHEN DAY(@StartDate) > DAY(@EndDate) THEN 1 ELSE 0 END
	SELECT @FechaTemp = DATEADD(m, @MonthsElapsed, @FechaTemp)
	SELECT @DaysElapsed = DATEDIFF(d, @FechaTemp, @EndDate)

	INSERT @ElapsedTime
		SELECT @YearsElapsed, @MonthsElapsed, @DaysElapsed

	RETURN
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2018-09-10
-- Description:	Returns a varchar that express the elapsed time in years, months and days
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetElapsedYearsMonthsAndDaysFromDays') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetElapsedYearsMonthsAndDaysFromDays
GO

CREATE FUNCTION udf_GetElapsedYearsMonthsAndDaysFromDays
(
	@DaysElapsed smallint
) RETURNS varchar(100) AS
BEGIN
	DECLARE @DaysInAYear smallint

	DECLARE @YearsElapsed smallint
	DECLARE @MonthsElapsed smallint
	DECLARE @ResultText varchar(100) = ''

	IF @DaysElapsed > 1460
		-- AS IS MORE THAN 4 YEARS, TAKE APROXIMATE ACCOUNT OF THE LEAP YEARS
		SET @DaysInAYear = 365.25
	ELSE
		SET @DaysInAYear = 365

	-- GETS ELAPSED YEARS AND THE REMAINING DAYS
	SET @YearsElapsed = @DaysElapsed / 365.25
	SET @DaysElapsed = @DaysElapsed % 365.25

	-- GET ELAPSED MONTHS AND THE REMAINING DAYS
	SET @MonthsElapsed = @DaysElapsed / 30
	SET @DaysElapsed = @DaysElapsed % 30

	IF @YearsElapsed > 0
		SET @ResultText = (CASE @YearsElapsed WHEN 0 THEN '' WHEN 1 THEN '1 año' ELSE CAST(@YearsElapsed AS varchar(3)) + ' años' END)
	IF @MonthsElapsed > 0
		SET @ResultText = @ResultText + (CASE @ResultText WHEN '' THEN '' ELSE (CASE @DaysElapsed WHEN 0 THEN ' y ' ELSE ', ' END) END) + (CASE @MonthsElapsed WHEN 0 THEN '' WHEN 1 THEN '1 mes' ELSE CAST(@MonthsElapsed AS varchar(3)) + ' meses' END)
	IF @DaysElapsed > 0
		SET @ResultText = @ResultText + (CASE @ResultText WHEN '' THEN '' ELSE ' y ' END) + (CASE @DaysElapsed WHEN 0 THEN '' WHEN 1 THEN '1 día' ELSE CAST(@DaysElapsed AS varchar(5)) + ' días' END)
	IF @ResultText > ''
		SET @ResultText = @ResultText + '.'

	RETURN @ResultText
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2018-09-11
-- Description:	Returns a varchar containing the elapsed time between two dates expressed in yers, months and days
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetElapsedYearsMonthsAndDaysFromDates') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetElapsedYearsMonthsAndDaysFromDates
GO

CREATE FUNCTION udf_GetElapsedYearsMonthsAndDaysFromDates
(	
	@StartDate date,
	@EndDate date
) RETURNS varchar(100) AS
BEGIN
	DECLARE @FechaTemp datetime
	DECLARE @YearsElapsed smallint
	DECLARE @MonthsElapsed smallint
	DECLARE @DaysElapsed smallint
	DECLARE @ResultText varchar(100) = ''

	SELECT @FechaTemp = @StartDate

	SELECT @YearsElapsed = DATEDIFF(yy, @FechaTemp, @EndDate) - CASE WHEN (MONTH(@StartDate) > MONTH(@EndDate)) OR (MONTH(@StartDate) = MONTH(@EndDate) AND DAY(@StartDate) > DAY(@EndDate)) THEN 1 ELSE 0 END
	SELECT @FechaTemp = DATEADD(yy, @YearsElapsed, @FechaTemp)
	SELECT @MonthsElapsed = DATEDIFF(m, @FechaTemp, @EndDate) - CASE WHEN DAY(@StartDate) > DAY(@EndDate) THEN 1 ELSE 0 END
	SELECT @FechaTemp = DATEADD(m, @MonthsElapsed, @FechaTemp)
	SELECT @DaysElapsed = DATEDIFF(d, @FechaTemp, @EndDate)

	IF @YearsElapsed > 0
		SET @ResultText = (CASE @YearsElapsed WHEN 0 THEN '' WHEN 1 THEN '1 año' ELSE CAST(@YearsElapsed AS varchar(3)) + ' años' END)
	IF @MonthsElapsed > 0
		SET @ResultText = @ResultText + (CASE @ResultText WHEN '' THEN '' ELSE (CASE @DaysElapsed WHEN 0 THEN ' y ' ELSE ', ' END) END) + (CASE @MonthsElapsed WHEN 0 THEN '' WHEN 1 THEN '1 mes' ELSE CAST(@MonthsElapsed AS varchar(3)) + ' meses' END)
	IF @DaysElapsed > 0
		SET @ResultText = @ResultText + (CASE @ResultText WHEN '' THEN '' ELSE ' y ' END) + (CASE @DaysElapsed WHEN 0 THEN '' WHEN 1 THEN '1 día' ELSE CAST(@DaysElapsed AS varchar(5)) + ' días' END)
	IF @ResultText > ''
		SET @ResultText = @ResultText + '.'

	RETURN @ResultText
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2018-10-29
-- Description:	Returns a varchar containing the elapsed time between two dates expressed in yers, months and days
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_FormatElapsedYearsMonthsAndDays') AND type = N'FN')
	DROP FUNCTION dbo.udf_FormatElapsedYearsMonthsAndDays
GO

CREATE FUNCTION udf_FormatElapsedYearsMonthsAndDays
(	
	@YearsElapsed smallint,
	@MonthsElapsed smallint,
	@DaysElapsed smallint
) RETURNS varchar(100) AS
BEGIN
	DECLARE @ResultText varchar(100) = ''

	IF @YearsElapsed > 0
		SET @ResultText = (CASE @YearsElapsed WHEN 0 THEN '' WHEN 1 THEN '1 año' ELSE CAST(@YearsElapsed AS varchar(3)) + ' años' END)
	IF @MonthsElapsed > 0
		SET @ResultText = @ResultText + (CASE @ResultText WHEN '' THEN '' ELSE (CASE @DaysElapsed WHEN 0 THEN ' y ' ELSE ', ' END) END) + (CASE @MonthsElapsed WHEN 0 THEN '' WHEN 1 THEN '1 mes' ELSE CAST(@MonthsElapsed AS varchar(3)) + ' meses' END)
	IF @DaysElapsed > 0
		SET @ResultText = @ResultText + (CASE @ResultText WHEN '' THEN '' ELSE ' y ' END) + (CASE @DaysElapsed WHEN 0 THEN '' WHEN 1 THEN '1 día' ELSE CAST(@DaysElapsed AS varchar(5)) + ' días' END)
	IF @ResultText > ''
		SET @ResultText = @ResultText + '.'

	RETURN @ResultText
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2018-10-04
-- Description:	Check if the year is a leap year
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_IsLeapYear') AND type = N'FN')
	DROP FUNCTION dbo.udf_IsLeapYear
GO

CREATE FUNCTION udf_IsLeapYear
(
	@Year smallint
) RETURNS bit AS
BEGIN
	RETURN (CASE WHEN (@YEAR % 4 = 0 AND @YEAR % 100 <> 0) OR @YEAR % 400 = 0 THEN 1 ELSE 0 END)
END
GO