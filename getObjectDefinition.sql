--Formas de obter a definição de um objeto


sp_helptext 'z_retorna_tempo_util_parametros_v2'
GO


SELECT    OBJECT_DEFINITION(OBJECT_ID('z_format_hhmmss'))
GO


SELECT    [definition]
FROM    sys.sql_modules
WHERE    object_id = OBJECT_ID('z_format_hhmmss')
GO