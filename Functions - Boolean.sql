SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2019-09-01
-- Description:	Returns 'X' char if bit value is 1
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_BitAsXChar') AND type = N'FN')
	DROP FUNCTION dbo.udf_BitAsXChar
GO

CREATE FUNCTION udf_BitAsXChar
(
	@Value bit
) RETURNS char(1) AS
BEGIN
	RETURN (CASE WHEN @Value = 1 THEN 'X' ELSE '' END)
END
GO