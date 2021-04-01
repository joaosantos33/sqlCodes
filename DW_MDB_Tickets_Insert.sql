

--filtro do período
---------------------------------------------------------------------------------------------------------------------------
declare @dt_ini_convertido integer
declare @dt_fim_convertido integer

set @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2017-01-01')
set @dt_fim_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2017-01-30')


--definindo as áreas Origem a serem contabilizadas
---------------------------------------------------------------------------------------------------------------------------
declare @areaOrigemAtualNome varchar(60)
declare @areaOrigemAtualId integer

declare @areasOrigem table (
	id integer,
	id_usd integer,
	name varchar(60)
	)

insert into @areasOrigem (id,id_usd,name) values (1,1000116,'GERÊNCIA CENTRAL DE ATENDIMENTO E NEGÓCIOS') --GERÊNCIA CENTRAL DE ATENDIMENTO E NEGÓCIOS
insert into @areasOrigem (id,id_usd,name) values (2,1000121,'GERÊNCIA OPERAÇÕES DE TI') --GERÊNCIA OPERAÇÕES DE TI
insert into @areasOrigem (id,id_usd,name) values (3,1000124,'GERÊNCIA SUPORTE AO COLABORADOR') --GERÊNCIA SUPORTE AO COLABORADOR


--definindo as equipes do N2: Sustentação e Infra-Estrutura
---------------------------------------------------------------------------------------------------------------------------
declare @equipesN2 table (
	id binary(16)
)

insert into @equipesN2
select  
grp.contact_uuid
from ca_contact grp
join ca_resource_department sub on sub.id = grp.department
where
grp.inactive = 0
and sub.z_srl_Parent in (
	1000002, --GERÊNCIA GESTÃO DE INCIDENTES E CAPACIDADE
	1000120, --GERÊNCIA INFRAESTRUTURA DE TI
	1000113  --GERÊNCIA DE APLICAÇÕES E PLATAFORMA DE TI
) 


--selecionando os tickets
---------------------------------------------------------------------------------------------------------------------------

declare @tickets table (
	ticket varchar(30),
	area varchar(60)
)

declare @c as integer
set @c = 1

while @c < 4
	begin

		set @areaOrigemAtualNome = (select top 1 name from @areasOrigem where id = @c)
		set @areaOrigemAtualId = (select top 1 id_usd from @areasOrigem where id = @c)

		insert into @tickets
		select cr.persid,@areaOrigemAtualNome
		from call_req cr
		where

		--filtrando tickets ABERTOS NO PERIODO
		cr.open_date between @dt_ini_convertido and @dt_fim_convertido

		-- incluindo Incidentes e Requisições
		and cr.type <> 'P'

		--registrados pela AREA ORIGEM SELECIONADA
		and cr.log_agent in (
			select distinct gm.member
			from grpmem gm
			where
			gm.group_id in (
				select 
				grp.contact_uuid
				from ca_contact grp
				join ca_resource_department sub on sub.id = grp.department
				where
				grp.inactive = 0
				and sub.z_srl_Parent = @areaOrigemAtualId
				and grp.last_name not like 'Aprovação%' --removendo grupos de aprovação da Base de Conhecimento
			)
		)

		set @c = @c + 1

	end

-- Após fazer a seleção dos tickets, temos que tratar a lista, pois alguns tickets podem aparecer mais de uma vez, no caso da pessoa
-- estar atrelada a mais de uma gerência (isso é um erro cadastral)
---------------------------------------------------------------------------------------------------------------------------
declare @ticketsValidos table (
	ticket varchar(30),
	area varchar(60)
)

insert into @ticketsValidos (ticket,area)
select t.ticket, MIN(t.area)
from @tickets t
group by t.ticket



	
-- Após selecionar os tickets, iremos buscar a informação de quais são os 1º e 2º grupos de SUS-INFRA a atender
---------------------------------------------------------------------------------------------------------------------------
declare @ticketsGrupos table (
	ticket varchar(30),
	grupo1 varchar(100),
	gerenciaGrupo1 varchar(100),
	dtInicioGrupo1 varchar(20),
	grupo2 varchar(100),
	gerenciaGrupo2 varchar(100),
	dtInicioGrupo2 varchar(20)
)



declare @ticket as varchar(30)
declare @grupo1 as varchar(100)
declare	@gerenciaGrupo1 as varchar(100)
declare	@dtInicioGrupo1 as varchar(20)
declare	@grupo2 as varchar(100)
declare	@gerenciaGrupo2 as varchar(100) 
declare	@dtInicioGrupo2 as varchar(20)

declare getGroups cursor for
select ticket 
from @ticketsValidos

open getGroups 
fetch next from getGroups into @ticket
	while @@FETCH_STATUS = 0
		begin
			--inicializando variaveis
			set @grupo1 = ''
			set @gerenciaGrupo1 = ''
			set @dtInicioGrupo1 = ''
			set @grupo2 = ''
			set @gerenciaGrupo2 = ''
			set @dtInicioGrupo2 = ''

			
			--pegando o nome e a data de atendimento do primeiro grupo
			select @grupo1 = COALESCE(grp.last_name,''), @dtInicioGrupo1 = COALESCE(dbo.z_retorna_datahora(cv2.z_dat_Inicio),'')
			from z_ciclo_vida cv2
			join ca_contact grp on grp.contact_uuid = cv2.z_srl_Grupo
			where 
			cv2.id = (
				select MIN(cv.id)
				from z_ciclo_vida cv 
				where cv.z_srl_CallReq = @ticket 
				and cv.z_srl_Grupo in (select id from @equipesN2)
			)

			--pegando a gerência do primeiro grupo
			select @gerenciaGrupo1 = COALESCE(ger.name,'')
			from z_ciclo_vida cv2
			join ca_contact grp on grp.contact_uuid = cv2.z_srl_Grupo
			join ca_resource_department coord on coord.id = grp.department
			join ca_resource_department ger on ger.id = coord.z_srl_Parent
			where 
			cv2.id = (
				select MIN(cv.id)
				from z_ciclo_vida cv 
				where cv.z_srl_CallReq = @ticket 
				and cv.z_srl_Grupo in (select id from @equipesN2)
			)

			--pegando o nome e a data de atendimento do segundo grupo
			select @grupo2 = COALESCE(grp.last_name,''),@dtInicioGrupo2 = COALESCE(dbo.z_retorna_datahora(cv2.z_dat_Inicio),'')
			from z_ciclo_vida cv2
			join ca_contact grp on grp.contact_uuid = cv2.z_srl_Grupo
			where 
			cv2.id = (
				select MIN(cv.id)
				from z_ciclo_vida cv 
				join ca_contact grp on grp.contact_uuid = cv.z_srl_Grupo
				where cv.z_srl_CallReq = @ticket 
				and grp.last_name <> @grupo1
				and cv.z_srl_Grupo in (select id from @equipesN2)
			)

			--pegando a gerência do segundo grupo
			select @gerenciaGrupo2 = COALESCE(ger.name,'')
			from z_ciclo_vida cv2
			join ca_contact grp on grp.contact_uuid = cv2.z_srl_Grupo
			join ca_resource_department coord on coord.id = grp.department
			join ca_resource_department ger on ger.id = coord.z_srl_Parent
			where 
			cv2.id = (
				select MIN(cv.id)
				from z_ciclo_vida cv 
				join ca_contact grp on grp.contact_uuid = cv.z_srl_Grupo
				where cv.z_srl_CallReq = @ticket 
				and grp.last_name <> @grupo1
				and cv.z_srl_Grupo in (select id from @equipesN2)
			)



			--inserindo os dados na tabela temporaria
			insert into @ticketsGrupos (ticket,grupo1,gerenciaGrupo1,dtInicioGrupo1,grupo2,gerenciaGrupo2,dtInicioGrupo2) 
			values 
			(
				@ticket,
				@grupo1,
				@gerenciaGrupo1,
				@dtInicioGrupo1,
				@grupo2,
				@gerenciaGrupo2,
				@dtInicioGrupo2
			)

	
			fetch next from getGroups into @ticket
		end
close getGroups
deallocate getGroups

--extraindo as informações dos tickets selecionados
---------------------------------------------------------------------------------------------------------------------------

select 
t.area as 'Área Origem'
, cr.ref_num as 'Ticket'
, cr.type as 'Tipo'
, tg.grupo1 as '1º Time Sus-Infra'
, tg.gerenciaGrupo1 as 'Gerência 1º Time Sus-Infra'
, tg.dtInicioGrupo1 as 'Entrada 1º Time Sus-Infra'
, tg.grupo2 as '2º Time Sus-Infra'
, tg.gerenciaGrupo2 as 'Gerência 2º Time Sus-Infra'
, tg.dtInicioGrupo2 as 'Entrada 2º Time Sus-Infra'
, pcat.sym as 'Categoria'
, cr.summary as 'Resumo'
, REPLACE(REPLACE(CONVERT(VARCHAR(4000),cr.description),Char(10) ,' '),';',' ') as 'Descrição'
, substring(dbo.z_retorna_data(cr.open_date),4,7) 'Ano/Mês Abertura'
, dbo.z_retorna_datahora(cr.open_date) 'Data Abertura'
, case 
	when cr.z_int_ItemGarantia = 1 then 'Sim'
	when cr.z_int_ItemGarantia = 2 then 'Sim'   
	else 'Não' 
end as 'Garantia'
, case when (select count(rec.id) from call_req rec where rec.zincidente = cr.persid) > 0 then 'Sim' else 'Não' end as 'É Ticket Origem?'
, COALESCE(pr.ref_num,'') as 'Problema'
, COALESCE(crs_pr.sym,'') as 'Status do Problema'
, cnt.last_name as 'Usuário'
, crs.sym as 'Status'
, pri.sym as 'Prioridade'
, COALESCE(urg.sym,'') as 'Urgência'
, imp.sym as 'Impacto'
, rep.last_name as 'Reportado Por'
, grp.last_name as 'Grupo Responsável'
, COALESCE(agt.last_name,'') as 'Responsável'
, COALESCE(grp_sol.last_name,'') as 'Grupo Solucionador'
, COALESCE(chg_causadora.chg_ref_num,'') as 'RDM Causadora'
, COALESCE(chg_solucionadora.chg_ref_num,'') as 'RDM Solucionadora'
, COALESCE(dbo.z_retorna_datahora(chg_solucionadora.zchgdata_exec_prod),'') as 'Data de Execução RDM Solucionadora'
, COALESCE(zsol.sym,'') as 'Categoria de Solução'
, COALESCE(dbo.z_retorna_datahora(cr.resolve_date),'') as 'Data Solução'
, COALESCE(dbo.z_retorna_datahora(cr.close_date),'') as 'Data Fechamento'
, CASE WHEN cr.z_int_Priorizado = 1 THEN 'Sim' ELSE 'Não' END as 'Priorizado?'
, fa.sym as 'Forma de Abertura'
, COALESCE(inc_origem.ref_num,'') as 'Incidente Origem'
, COALESCE(pai.ref_num,'') as 'Incidente Pai'

from @ticketsValidos t
join call_req cr on cr.persid = t.ticket
join @ticketsGrupos tg on tg.ticket = cr.persid
join prob_ctg pcat on pcat.persid = cr.category
left join call_req pr on pr.persid = cr.problem
left join cr_stat crs_pr on crs_pr.code = pr.status
join ca_contact cnt on cnt.contact_uuid = cr.customer 
join ca_contact grp on grp.contact_uuid = cr.group_id 
join ca_contact rep on rep.contact_uuid = cr.log_agent
left join ca_contact agt on agt.contact_uuid = cr.assignee 
left join ca_contact grp_sol on grp_sol.contact_uuid = cr.z_srl_GrupoSolucionador 
join cr_stat crs on  crs.code = cr.status
join pri on pri.enum = cr.priority
left join urgncy urg on urg.enum = cr.urgency
left join impact imp on imp.enum = cr.impact
left join call_req pai on pai.persid = cr.parent
left join chg chg_solucionadora on chg_solucionadora.id = cr.change
left join chg chg_causadora on chg_causadora.id = cr.caused_by_chg
left join zsolucao zsol on zsol.id = cr.zsolucao
join zforma_abertura fa on fa.code = cr.zforma_abertura
left join call_req inc_origem on inc_origem.persid = cr.zincidente
