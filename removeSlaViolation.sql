
declare @numTicket as varchar(30)

set @numTicket = '22918117'


select sg.id as 'ID para alterar', sg.z_int_Violado100 as 'Colocar 0 nesse campo',cr.ref_num,cr.sla_violation,cr.predicted_sla_viol, grp.last_name, cr.open_date, sg.*
from call_req cr
join z_obj_ServicoPorGrupo sg on sg.z_srl_Cr = cr.persid
join ca_contact grp on grp.contact_uuid = sg.z_srl_Grupo
where
cr.ref_num = @numTicket
and sg.z_srl_Grupo is not null
