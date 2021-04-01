select 
 dbo.z_retorna_datahora(cv.z_dat_inicio) as inicio
,dbo.z_retorna_datahora(cv.z_dat_Fim) as fim
,concat(cv.id,';',
dbo.z_retorna_tempo_util_parametros(dateadd(s,z_dat_inicio,'1969-12-31 21:00:00'),dateadd(s,z_dat_Fim,'1969-12-31 21:00:00'),'09:00','18:00',0) ,';',(z_dat_Fim - z_dat_inicio) 
) as Carga
 
from 
call_req cr
join z_ciclo_vida cv on cv.z_srl_CallReq  = cr.persid
where
cr.open_date> 1612137246
and cr.group_id in (
    0xC84DE6EE0FAAB448A2ECFB8028481E0A,
	0xFB61A27AAE01EF43945C79AEE05A0F69,
	0x99AC3DAF0D4AFF4BB50B85B9AC9EF406,
	0x7B13F4D3F0B79E448C5E5CC24825634A
)
and cv.z_dat_Fim is not null
and cv.z_dur_TempoUtil is null