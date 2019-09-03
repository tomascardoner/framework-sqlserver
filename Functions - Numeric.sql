SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2019-09-02
-- Description:	Returns 'X' char if both input values are equal
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_EqualValueAsXChar') AND type = N'FN')
	DROP FUNCTION dbo.udf_EqualValueAsXChar
GO

CREATE FUNCTION udf_EqualValueAsXChar
(
	@Value1 tinyint,
	@Value2 tinyint
) RETURNS char(1) AS
BEGIN
	RETURN (CASE WHEN @Value1 = @Value2 THEN 'X' ELSE '' END)
END
GO