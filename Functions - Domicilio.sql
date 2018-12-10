SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2013-08-25
-- Updates: 2015-06-26
-- Description:	Devuelve el Domicilio (Calle) completo
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetDomicilioCalleCompleto') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetDomicilioCalleCompleto
GO

CREATE FUNCTION udf_GetDomicilioCalleCompleto 
(	
	@Calle1 varchar(100),
	@Numero varchar(10),
	@Piso varchar(10),
	@Departamento varchar(10),
	@Calle2 varchar(50),
	@Calle3 varchar(50)
) RETURNS varchar(250) AS
BEGIN
	DECLARE @ReturnValue varchar(250)

	SET @ReturnValue = ''

	--VERIFICO QUE ESTÉ ESPECIFICADA COMO MÍNIMO LA CALLE1
	IF @Calle1 IS NOT NULL
		BEGIN
		SET @ReturnValue = @Calle1

		--SI ESTÁ ESPECIFICADA LA ALTURA
		IF @Numero IS NOT NULL
			BEGIN
			--VERIFICO SI NO ES UNA RUTA
			IF UPPER(SUBSTRING(@Calle1, 1, 5)) = 'RUTA '
				BEGIN
				SET @ReturnValue = @ReturnValue + ' Km. ' + @Numero
				END
			ELSE
				BEGIN
				--O ES UNA 'CALLE'
				IF UPPER(SUBSTRING(@Calle1, 1, 6)) = 'CALLE '
					BEGIN
					IF ISNUMERIC(SUBSTRING(@Calle1, 7, 50)) = 1
						BEGIN
						SET @ReturnValue = @ReturnValue + ' N° ' + @Numero
						END
					ELSE
						BEGIN
						SET @ReturnValue = @ReturnValue + ' ' + @Numero
						END
					END
				ELSE
					BEGIN
					--O ES UN NÚMERO SÓLO (CALLE)
					if ISNUMERIC(@Calle1) = 1
						BEGIN
						SET @ReturnValue = 'Calle ' + @Calle1 + ' N° ' + @Numero
						END
					ELSE
						BEGIN
						SET @ReturnValue = @ReturnValue + ' ' + @Numero
						END
					END
				END

			--SI ESPECIFICA EL PISO
			IF @Piso IS NOT NULL
				BEGIN
				if ISNUMERIC(@Piso) = 1
					BEGIN
					SET @ReturnValue = @ReturnValue + ' P.' + @Piso + '°'
					END
				ELSE
					BEGIN
					SET @ReturnValue = @ReturnValue + ' ' + @Piso
					END
				END
			--SI ESPECIFICA EL DEPARTAMENTO
			IF @Departamento IS NOT NULL
				BEGIN
				SET @ReturnValue = @ReturnValue + ' Dto. "' + @Departamento + '"'
				END
			END

		--SI ESPECIFICA LA CALLE2
		IF @Calle2 IS NOT NULL
			BEGIN
			IF @Calle3 IS NOT NULL
				BEGIN
				SET @ReturnValue = @ReturnValue + ' entre ' + @Calle2 + ' y ' + @Calle3
				END
			ELSE
				BEGIN
				SET @ReturnValue = @ReturnValue + ' esq. ' + @Calle2
				END
			END
		END
	
	RETURN @ReturnValue
END
GO




-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2013-08-25
-- Description:	Devuelve el Código Postal y la Localidad formateados
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetCodigoPostalLocalidad') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetCodigoPostalLocalidad
GO

CREATE FUNCTION udf_GetCodigoPostalLocalidad 
(	
	@CodigoPostal varchar(8),
	@IDProvincia tinyint,
	@IDLocalidad smallint
) RETURNS varchar(111) AS
BEGIN
	DECLARE @LocalidadNombre varchar(100)
	DECLARE @ReturnValue varchar(111)

	SET @LocalidadNombre = (SELECT Nombre FROM Localidad WHERE IDProvincia = @IDProvincia AND IDLocalidad = @IDLocalidad)
	SET @ReturnValue = ''

	IF @LocalidadNombre IS NOT NULL
		BEGIN
		IF @CodigoPostal IS NOT NULL
			BEGIN
			SET @ReturnValue = '(' + @CodigoPostal + ') '
			END
		SET @ReturnValue = @ReturnValue + @LocalidadNombre
		END
	
	RETURN @ReturnValue
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2016-12-31
-- Description:	Devuelve el Domicilio (Calle + Localidad) completo
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetDomicilioCalleLocalidadCompleto') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetDomicilioCalleLocalidadCompleto
GO

CREATE FUNCTION udf_GetDomicilioCalleLocalidadCompleto 
(	
	@Calle1 varchar(100),
	@Numero varchar(10),
	@Piso varchar(10),
	@Departamento varchar(10),
	@Calle2 varchar(50),
	@Calle3 varchar(50),
	@IDProvincia tinyint,
	@IDLocalidad smallint
) RETURNS varchar(400) AS
BEGIN
	DECLARE @ReturnValue varchar(400)
	DECLARE @LocalidadNombre varchar(100)

	SET @ReturnValue = dbo.udf_GetDomicilioCalleCompleto(@Calle1, @Numero, @Piso, @Departamento, @Calle2, @Calle3)
	SET @LocalidadNombre = (SELECT Nombre FROM Localidad WHERE IDProvincia = @IDProvincia AND IDLocalidad = @IDLocalidad)
	IF @ReturnValue <> ''
		BEGIN
		IF @LocalidadNombre <> ''
			BEGIN
			SET @ReturnValue = @ReturnValue + ' - ' + @LocalidadNombre
			END
		END

	RETURN @ReturnValue
END
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2015-06-26
-- Description:	Devuelve el Domicilio (Calle + Codigo Postal + Localidad + Provincia) completo
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udf_GetDomicilioCompleto') AND type = N'FN')
	DROP FUNCTION dbo.udf_GetDomicilioCompleto
GO

CREATE FUNCTION udf_GetDomicilioCompleto 
(	
	@Calle1 varchar(100),
	@Numero varchar(10),
	@Piso varchar(10),
	@Departamento varchar(10),
	@Calle2 varchar(50),
	@Calle3 varchar(50),
	@CodigoPostal varchar(8),
	@IDProvincia tinyint,
	@IDLocalidad smallint
) RETURNS varchar(400) AS
BEGIN
	DECLARE @ReturnValue varchar(400)
	DECLARE @CodigoPostalLocalidad varchar(111)
	DECLARE @ProvinciaNombre varchar(50)

	SET @ProvinciaNombre = (SELECT Nombre FROM Provincia WHERE IDProvincia = @IDProvincia)

	SET @ReturnValue = dbo.udf_GetDomicilioCalleCompleto(@Calle1, @Numero, @Piso, @Departamento, @Calle2, @Calle3)
	SET @CodigoPostalLocalidad = dbo.udf_GetCodigoPostalLocalidad(@CodigoPostal, @IDProvincia, @IDLocalidad)
	IF @ReturnValue <> ''
		BEGIN
		IF @CodigoPostalLocalidad <> ''
			BEGIN
			SET @ReturnValue = @ReturnValue + ' - ' + @CodigoPostalLocalidad
			IF @ProvinciaNombre IS NOT NULL
				BEGIN
				SET @ReturnValue = @ReturnValue + ', ' + @ProvinciaNombre
				END
			END
		ELSE
			BEGIN
			IF @ProvinciaNombre IS NOT NULL
				BEGIN
				SET @ReturnValue = @ReturnValue + ' - ' + @ProvinciaNombre
				END
			END
		END

	RETURN @ReturnValue
END
GO