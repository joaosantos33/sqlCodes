--Coisas uteis em geral


-- Coloca informações de várias linhas em uma unica coluna----------------------------------------------------------------------------------

SELECT Stuff(
  (SELECT N', ' + att.attmnt_name + ' - ' +
	case att.status 
	WHEN 'INSTALLED' then 'Instalado'
	WHEN 'LINK_ONLY' then 'Apenas link'
	WHEN 'NOTINSTALLED' then 'N�o instalado'
	WHEN 'ARCHIVED' then 'Arquivado'
	WHEN 'NOTAVAILABLE' then 'N�o dispon�vel'
	else '' end
  FROM 
	dbo.attmnt att with(nolock)
	left join usp_lrel_attachments_requests attReq with(nolock) on att.id = attReq.attmnt
	left join call_req crAtt with(nolock) on attReq.cr = crAtt.persid
	where crAtt.id = cr.id
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)



Stuff(
  (SELECT distinct N', ' + grp.last_name	 
   FROM z_ciclo_vida cv with(nolock)
	join ca_contact grp on grp.contact_uuid = cv.z_srl_Grupo
	where cv.z_srl_CallReq = inc.persid
  FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,2,N'') as 'Grupos que Atenderam'




  --ultima parte da cartegoria----------------------------------------------------------------------------------
select REVERSE(SUBSTRING(  REVERSE(SUBSTRING(PROB_CTG.SYM,PATINDEX('%.%',PROB_CTG.SYM)+1,LEN(PROB_CTG.SYM))),
            PATINDEX('%.%',REVERSE(SUBSTRING(PROB_CTG.SYM,PATINDEX('%.%',PROB_CTG.SYM)+1,LEN(PROB_CTG.SYM)))) + 1,
                       LEN(REVERSE(SUBSTRING(PROB_CTG.SYM,PATINDEX('%.%',PROB_CTG.SYM)+1,LEN(PROB_CTG.SYM))))
            ))as 'Ultima parte da categoria'



--UTIL PARA USAR EM SCRIPTS

SELECT 'categories[' + CONVERT(varchar, ROW_NUMBER() OVER(ORDER BY pcat.persid) - 1) + '] = "' + pcat.persid + '";'



--código para obter valor de propriedades nos relatório
, (select p.value from cr_prp p where p.id = (select MAX(p.id) from cr_prp p where p.owning_cr = cr.persid and p.label = '') )  as ''