DECLARE @dt_ini_convertido AS INTEGER
DECLARE @dt_fim_convertido AS INTEGER

SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2018-01-01')
SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2018-12-31')

SELECT top 10
cr.ref_num as 'Requisição',
cnt.last_name as 'Usuário',
ent.last_name as 'Entidada Afetada',
grp.last_name as 'Grupo Responsável',
COALESCE(agt.last_name,'') as 'Responsável',
COALESCE(grp_sol.last_name,'') as 'Grupo Solucionador',
COALESCE(agt_sol.last_name,'') as 'Analista Solucionador',
rep.last_name as 'Reportado Por',
cr.summary as 'Resumo',
cr.description as 'Descrição',
dbo.z_retorna_datahora(cr.open_date) as 'Data Abertura',
SUBSTRING(dbo.z_retorna_datahora(cr.open_date),4,8) as 'Mes/Ano Data Abertura',
COALESCE(dbo.z_retorna_datahora(cr.resolve_date),'') as 'Data Solução',
COALESCE(dbo.z_retorna_datahora(cr.close_date),'') as 'Data Fechamento',
crs.sym as 'Status',
pcat.sym as 'Categoria',
COALESCE(zsol.sym,'') as 'Solução'
FROM call_req cr WITH(NOLOCK)
JOIN ca_contact cnt WITH(NOLOCK) ON cnt.contact_uuid = cr.customer 
JOIN ca_contact grp WITH(NOLOCK) ON grp.contact_uuid = cr.group_id 
LEFT JOIN ca_contact ent WITH(NOLOCK) ON ent.contact_uuid = cr.zrequisitante
JOIN ca_contact rep WITH(NOLOCK) ON rep.contact_uuid = cr.log_agent
LEFT JOIN ca_contact agt WITH(NOLOCK) ON agt.contact_uuid = cr.assignee 
LEFT JOIN ca_contact grp_sol WITH(NOLOCK) ON grp_sol.contact_uuid = cr.z_srl_GrupoSolucionador 
LEFT JOIN ca_contact agt_sol WITH(NOLOCK) ON agt_sol.contact_uuid = cr.z_srl_AnalistaSolucionador
JOIN cr_stat crs WITH(NOLOCK) ON crs.code = cr.status
JOIN prob_ctg pcat WITH(NOLOCK) ON pcat.persid = cr.category
LEFT JOIN zsolucao zsol  WITH(NOLOCK) ON zsol.id = cr.zsolucao
WHERE
cr.type = 'R'
and cr.open_date between @dt_ini_convertido and @dt_fim_convertido