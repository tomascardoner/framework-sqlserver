SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el valor de texto de un parámetro
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetParametro_Texto') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetParametro_Texto
GO

CREATE FUNCTION udf_GetParametro_Texto
(	
	@IDParametro char(100)
) RETURNS varchar(1000) AS
BEGIN
	RETURN (SELECT Texto FROM Parametro WHERE IDParametro = @IDParametro)
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el valor de número entero de un parámetro
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetParametro_NumeroEntero') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetParametro_NumeroEntero
GO

CREATE FUNCTION udf_GetParametro_NumeroEntero
(	
	@IDParametro char(100)
) RETURNS int AS
BEGIN
	RETURN (SELECT NumeroEntero FROM Parametro WHERE IDParametro = @IDParametro)
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el valor de número decimal de un parámetro
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetParametro_NumeroDecimal') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetParametro_NumeroDecimal
GO

CREATE FUNCTION udf_GetParametro_NumeroDecimal
(	
	@IDParametro char(100)
) RETURNS decimal(18,0) AS
BEGIN
	RETURN (SELECT NumeroDecimal FROM Parametro WHERE IDParametro = @IDParametro)
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el valor de moneda de un parámetro
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetParametro_Moneda') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetParametro_Moneda
GO

CREATE FUNCTION udf_GetParametro_Moneda
(	
	@IDParametro char(100)
) RETURNS money AS
BEGIN
	RETURN (SELECT Moneda FROM Parametro WHERE IDParametro = @IDParametro)
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el valor de fecha y hora de un parámetro
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetParametro_FechaHora') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetParametro_FechaHora
GO

CREATE FUNCTION udf_GetParametro_FechaHora
(	
	@IDParametro char(100)
) RETURNS smalldatetime AS
BEGIN
	RETURN (SELECT FechaHora FROM Parametro WHERE IDParametro = @IDParametro)
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el valor Si/no de un parámetro
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetParametro_SiNo') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetParametro_SiNo
GO

CREATE FUNCTION udf_GetParametro_SiNo
(	
	@IDParametro char(100)
) RETURNS bit AS
BEGIN
	RETURN (SELECT SiNo FROM Parametro WHERE IDParametro = @IDParametro)
END
GO