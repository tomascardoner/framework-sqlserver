SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Tomás A. Cardoner
-- Create date: 2013-08-25
-- Updates: 2015-06-26
--          2020-09-26 - se cambió el nombre de la función y otras mínimas correcciones
-- Description:	Devuelve el Domicilio (Calle) completo
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udfObtenerDomicilioCalleCompleto') AND type = N'FN')
	DROP FUNCTION dbo.udfObtenerDomicilioCalleCompleto
GO

CREATE FUNCTION udfObtenerDomicilioCalleCompleto 
(	
	@Calle1 varchar(100),
	@Numero varchar(10),
	@Piso varchar(10),
	@Departamento varchar(10),
	@Calle2 varchar(50),
	@Calle3 varchar(50),
	@Barrio varchar(50)
) RETURNS varchar(300) AS
BEGIN
	DECLARE @ReturnValue varchar(300)

	SET @ReturnValue = ''

	-- Verifico que, al menos, esté especificada la calle 1
	IF @Calle1 IS NOT NULL
		BEGIN
		SET @ReturnValue = @Calle1

		-- Verifico si se especificó la altura
		IF @Numero IS NOT NULL
			BEGIN
			-- Verifico si es una ruta
			IF UPPER(SUBSTRING(@Calle1, 1, 5)) = 'RUTA '
				BEGIN
				SET @ReturnValue = @ReturnValue + ' km. ' + @Numero
				END
			ELSE
				BEGIN
				-- Verifico si está la palabra 'calle'
				IF UPPER(SUBSTRING(@Calle1, 1, 6)) = 'CALLE '
					BEGIN
					IF ISNUMERIC(SUBSTRING(@Calle1, 7, 50)) = 1
						BEGIN
						SET @ReturnValue = @ReturnValue + ' n° ' + @Numero
						END
					ELSE
						BEGIN
						SET @ReturnValue = @ReturnValue + ' ' + @Numero
						END
					END
				ELSE
					BEGIN
					-- Verifico si el nombre de la calle es sólo un número
					IF ISNUMERIC(@Calle1) = 1
						BEGIN
						SET @ReturnValue = 'Calle ' + @Calle1 + ' n° ' + @Numero
						END
					ELSE
						BEGIN
						SET @ReturnValue = @ReturnValue + ' ' + @Numero
						END
					END
				END

			-- Verifico si especifica el piso
			IF @Piso IS NOT NULL
				BEGIN
				IF ISNUMERIC(@Piso) = 1
					BEGIN
					SET @ReturnValue = @ReturnValue + ' p.' + @Piso + '°'
					END
				ELSE
					BEGIN
					SET @ReturnValue = @ReturnValue + ' ' + @Piso
					END
				END
			-- Verifico si especifica el departamento
			IF @Departamento IS NOT NULL
				BEGIN
				SET @ReturnValue = @ReturnValue + ' dto."' + @Departamento + '"'
				END
			END

		-- Verifico si especifica la calle 2 y la calle 3
		IF @Calle2 IS NOT NULL
			BEGIN
			IF @Calle3 IS NOT NULL
				-- Especifica calle 2 y calle 3
				BEGIN
				IF ISNUMERIC(@Calle1) = 1
					BEGIN
					SET @ReturnValue = @ReturnValue + ' entre ' + @Calle2 + ' y ' + @Calle3
					END
				ELSE
					BEGIN
					IF ISNUMERIC(@Calle2) = 1
						BEGIN
						IF ISNUMERIC(@Calle3) = 1
							BEGIN
							SET @ReturnValue = @ReturnValue + ' entre Calles ' + @Calle2 + ' y ' + @Calle3
							END
						ELSE
							BEGIN
							SET @ReturnValue = @ReturnValue + ' entre Calle ' + @Calle2 + ' y ' + @Calle3
							END
						END
					ELSE
						BEGIN
						IF ISNUMERIC(@Calle3) = 1
							BEGIN
							SET @ReturnValue = @ReturnValue + ' entre ' + @Calle2 + ' y Calle ' + @Calle3
							END
						ELSE
							BEGIN
							SET @ReturnValue = @ReturnValue + ' entre ' + @Calle2 + ' y ' + @Calle3
							END
						END
					END
				END
			ELSE
				-- Sólo especifica la calle 2
				BEGIN
				IF @Numero IS NOT NULL
					-- Ya se procesó el nombre de la calle 1, sólo proceso el de la calle 2
					BEGIN
					IF ISNUMERIC(@Calle1) = 0 AND ISNUMERIC(@Calle2) = 1
						BEGIN
						SET @ReturnValue = @ReturnValue + ' esq. Calle ' + @Calle2
						END
					ELSE
						BEGIN
						SET @ReturnValue = @ReturnValue + ' esq. ' + @Calle2
						END
					END
				ELSE
					-- Todavía no se procesó la calle 1, así que proceso ambas
					BEGIN
					IF ISNUMERIC(@Calle1) = 1
						BEGIN
						SET @ReturnValue = 'Calle ' + @Calle1 + ' esq. ' + @Calle2
						END
					ELSE
						BEGIN
						IF ISNUMERIC(@Calle2) = 1
							BEGIN
							SET @ReturnValue = @Calle1 + ' esq. Calle ' + @Calle2
							END
						ELSE
							BEGIN
							SET @ReturnValue = @Calle1 + ' esq. ' + @Calle2
							END
						END
					END
				END
			END
		ELSE
			-- No especifica la calle 2 pero hay que verificar la calle 1
			BEGIN
			IF @Numero IS NULL
				BEGIN
				IF ISNUMERIC(@Calle1) = 1
					BEGIN
					SET @ReturnValue = 'Calle ' + @Calle1
					END
				ELSE
					BEGIN
					SET @ReturnValue = @Calle1
					END
				END
			END

		-- Verifico si especifica el barrio
		IF @Barrio IS NOT NULL
			BEGIN
			SET @ReturnValue = @ReturnValue + ' - ' + @Barrio
			END

		END
	ELSE
		BEGIN
		--SI ESPECIFICA EL BARRIO
		IF @Barrio IS NOT NULL
			BEGIN
			SET @ReturnValue = @Barrio
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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udfObtenerCodigoPostalLocalidad') AND type = N'FN')
	DROP FUNCTION dbo.udfObtenerCodigoPostalLocalidad
GO

CREATE FUNCTION udfObtenerCodigoPostalLocalidad 
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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udfObtenerDomicilioCalleLocalidadCompleto') AND type = N'FN')
	DROP FUNCTION dbo.udfObtenerDomicilioCalleLocalidadCompleto
GO

CREATE FUNCTION udfObtenerDomicilioCalleLocalidadCompleto 
(	
	@Calle1 varchar(100),
	@Numero varchar(10),
	@Piso varchar(10),
	@Departamento varchar(10),
	@Calle2 varchar(50),
	@Calle3 varchar(50),
	@Barrio varchar(50),
	@IDProvincia tinyint,
	@IDLocalidad smallint
) RETURNS varchar(400) AS
BEGIN
	DECLARE @ReturnValue varchar(400)
	DECLARE @LocalidadNombre varchar(100)

	SET @ReturnValue = dbo.udfObtenerDomicilioCalleCompleto(@Calle1, @Numero, @Piso, @Departamento, @Calle2, @Calle3, @Barrio)
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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.udfObtenerDomicilioCompleto') AND type = N'FN')
	DROP FUNCTION dbo.udfObtenerDomicilioCompleto
GO

CREATE FUNCTION udfObtenerDomicilioCompleto 
(	
	@Calle1 varchar(100),
	@Numero varchar(10),
	@Piso varchar(10),
	@Departamento varchar(10),
	@Calle2 varchar(50),
	@Calle3 varchar(50),
	@Barrio varchar(50),
	@CodigoPostal varchar(8),
	@IDProvincia tinyint,
	@IDLocalidad smallint
) RETURNS varchar(400) AS
BEGIN
	DECLARE @ReturnValue varchar(400)
	DECLARE @CodigoPostalLocalidad varchar(111)
	DECLARE @ProvinciaNombre varchar(50)

	SET @ProvinciaNombre = (SELECT Nombre FROM Provincia WHERE IDProvincia = @IDProvincia)

	SET @ReturnValue = dbo.udfObtenerDomicilioCalleCompleto(@Calle1, @Numero, @Piso, @Departamento, @Calle2, @Calle3, @Barrio)
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