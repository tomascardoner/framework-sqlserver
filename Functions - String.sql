SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2019-09-01
-- Description:	Returns the input string as Camel Case
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udfStringCamelCase') AND type = N'FN')
	DROP FUNCTION dbo.udfStringCamelCase
GO

CREATE FUNCTION udfStringCamelCase
	(@InputString varchar(8000))
	RETURNS varchar(8000) AS

	BEGIN
	DECLARE @Index          int
	DECLARE @Char           char(1)
	DECLARE @PrevChar       char(1)
	DECLARE @OutputString   varchar(255)

	SET @OutputString = LOWER(@InputString)
	SET @Index = 1

	WHILE @Index <= LEN(@InputString)
		BEGIN
			SET @Char     = SUBSTRING(@InputString, @Index, 1)
			SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
								 ELSE SUBSTRING(@InputString, @Index - 1, 1)
							END

			IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
			BEGIN
				IF @PrevChar != '''' OR UPPER(@Char) != 'S'
					SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
			END

			SET @Index = @Index + 1
		END

	RETURN @OutputString

	END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2019-09-02
-- Description:	Returns the input string padded to the right
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udfStringPadLeft') AND type = N'FN')
	DROP FUNCTION dbo.udfStringPadLeft
GO

CREATE FUNCTION udfStringPadLeft
(
	@InputString varchar(8000),
	@TotalWidth tinyint,
	@PaddingChar char(1)
)
RETURNS varchar(8000) AS

	BEGIN

	RETURN REPLACE(STR(@InputString, @TotalWidth), SPACE(1), @PaddingChar)

	END
GO