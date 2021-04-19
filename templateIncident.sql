DECLARE @dt_ini_convertido AS INTEGER
DECLARE @dt_fim_convertido AS INTEGER

SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2018-01-01')
SET @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2018-12-31')

SELECT 
inc.ref_num as 'Incidente',
cnt.last_name as 'Usuário',
ent.last_name as 'Entidada Afetada',
grp.last_name as 'Grupo Responsável',
COALESCE(agt.last_name,'') as 'Responsável',
COALESCE(grp_sol.last_name,'') as 'Grupo Solucionador',
COALESCE(agt_sol.last_name,'') as 'Analista Solucionador',
rep.last_name as 'Reportado Por',
inc.summary as 'Resumo',
inc.description as 'Descrição',
dbo.z_retorna_datahora(inc.open_date) as 'Data Abertura',
SUBSTRING(dbo.z_retorna_datahora(inc.open_date),4,8) as 'Mes/Ano Data Abertura',
COALESCE(dbo.z_retorna_datahora(inc.resolve_date),'') as 'Data Solução',
COALESCE(dbo.z_retorna_datahora(inc.close_date),'') as 'Data Fechamento',
crs.sym as 'Status',
pri.sym as 'Prioridade',
urg.sym as 'Urgência',
imp.sym as 'Impacto',
pcat.sym as 'Categoria',
COALESCE(inc_ori.ref_num,'') as 'Incidente Origem',
COALESCE(pr.ref_num,'') as 'Problema',
COALESCE(pai.ref_num,'') as 'Incidente Pai',
COALESCE(chg.chg_ref_num,'') as 'RDM Solucionadora',
COALESCE(chg_causadora.chg_ref_num,'') as 'RDM Causadora',
COALESCE(zsol.sym,'') as 'Solução',
CASE WHEN inc.zcontorno = 1 THEN 'Sim' ELSE 'Não' END as 'Solução de Contorno?'
FROM call_req inc WITH(NOLOCK)
JOIN ca_contact cnt WITH(NOLOCK) ON cnt.contact_uuid = inc.customer 
JOIN ca_contact grp WITH(NOLOCK) ON grp.contact_uuid = inc.group_id 
LEFT JOIN ca_contact ent WITH(NOLOCK) ON ent.contact_uuid = inc.zrequisitante
JOIN ca_contact rep WITH(NOLOCK) ON rep.contact_uuid = inc.log_agent
LEFT JOIN ca_contact agt WITH(NOLOCK) ON agt.contact_uuid = inc.assignee 
LEFT JOIN ca_contact grp_sol WITH(NOLOCK) ON grp_sol.contact_uuid = inc.z_srl_GrupoSolucionador 
LEFT JOIN ca_contact agt_sol WITH(NOLOCK) ON agt_sol.contact_uuid = inc.z_srl_AnalistaSolucionador
JOIN cr_stat crs WITH(NOLOCK) ON crs.code = inc.status
JOIN pri WITH(NOLOCK) ON pri.enum = inc.priority
LEFT JOIN urgncy urg WITH(NOLOCK) ON urg.enum = inc.urgency
LEFT JOIN impact imp WITH(NOLOCK) ON imp.enum = inc.impact
JOIN prob_ctg pcat WITH(NOLOCK) ON pcat.persid = inc.category
LEFT JOIN call_req inc_ori WITH(NOLOCK) ON inc_ori.persid = inc.zincidente
LEFT JOIN call_req pr WITH(NOLOCK) ON pr.persid = inc.problem
LEFT JOIN call_req pai WITH(NOLOCK) ON pai.persid = inc.parent
LEFT JOIN chg  WITH(NOLOCK) ON chg.id = inc.change
LEFT JOIN chg chg_causadora  WITH(NOLOCK) ON chg_causadora.id = inc.caused_by_chg
LEFT JOIN zsolucao zsol  WITH(NOLOCK) ON zsol.id = inc.zsolucao
WHERE
inc.type = 'I'
and inc.open_date between @dt_ini_convertido and @dt_fim_convertido