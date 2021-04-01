--Códigos uteis de tratamento de datas



--Conversao tradicional de datas
DECLARE @dt_ini_convertido AS INTEGER
DECLARE @dt_fim_convertido AS INTEGER
      
SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',@dt_ini)
SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00',@dt_fim)



--Retorna o começo do dia atual
SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,GETDATE(),111) + ' 00:00:00')

--Retorna o 1 dia do mês atual
SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,YEAR(getdate())) +'-' + CONVERT(VARCHAR,MONTH(getdate())) + '-1 00:00:00')

--Retorna o mes passado
SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,DATEADD(M,-1,GETDATE()),111) + ' 00:00:00')
SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,DATEADD(D,-1,GETDATE()),111) + ' 23:59:59')

--Retorna o número de dias desde a abertura
select DATEDIFF(d,DATEADD(ss,cr.open_date,'1969-12-31 21:00:00'),GETDATE()) as 'Dias da Abertura'



--Retorna o numero de dias desde a ultima troca de status
select DATEDIFF(dd,DATEADD(ss,
	(
	SELECT alg.system_time
	FROM act_log alg
	WHERE alg.call_req_id = cr.persid
	and alg.type = 'ST'
	ORDER BY alg.id DESC
	)
	,'1969-12-31 21:00:00'),getdate()) as 'Dias desde o �ltimo Status'


-- estrutura para adicionar calculo automatico de dadas em relatórios agendados
IF @agendamento = 0 --sem agendamento
	BEGIN	
		SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',@dt_ini)
		SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00',@dt_fim)	
	END
ELSE IF @agendamento = 1 -- mes passado
    BEGIN   
		SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,DATEADD(M,-1,GETDATE()),111) + ' 00:00:00')
		SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,DATEADD(D,-1,GETDATE()),111) + ' 23:59:59')
	END
ELSE IF @agendamento = 2 -- mes atual
    BEGIN   
		SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00',CONVERT(VARCHAR,YEAR(getdate())) +'-' + CONVERT(VARCHAR,MONTH(getdate())) + '-1 00:00:00')
		SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00',GETDATE())
	END