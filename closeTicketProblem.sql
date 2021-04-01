
declare @numTicket as varchar(30)

set @numTicket = '22918117'


select sg.id as 'ID para alterar do objeto z_obj_ServicoPorGrupo', cr.ref_num, cr.open_date as 'Essa é a data de abertura', sg.z_dat_Inicio as 'Colocar a data de abertura nesse campo', sg.z_dat_Quebra as 'Colocar a data de abertura nesse campo'
from call_req cr
join z_obj_ServicoPorGrupo sg on sg.z_srl_Cr = cr.persid
join ca_contact grp on grp.contact_uuid = sg.z_srl_Grupo
where
cr.ref_num = @numTicket
and sg.z_srl_Grupo is not null


-- select cr.ref_num,cr.sla_violation,cr.predicted_sla_viol
-- from call_req cr
-- where
-- cr.ref_num = @numTicket

-- z_dat_Inicio z_dat_Quebra


--select * from cr_stat with(nolock) where sym like 'pen%'