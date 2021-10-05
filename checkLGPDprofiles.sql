-- script para verificar se tem algum usuário com perfil indevido no USD com relação a LGPD

select cnt.userid
from ca_contact cnt
join usp_contact u on u.contact_uuid = cnt.contact_uuid
join acctyp_v2 a on a.id = u.c_acctyp_id
where
cnt.inactive = 0 
and u.zcargo not in ('Analista de Atendimento Segmentado JR'
,'Analista de Compliance JR','Analista de Compliance PL','Analista de Segurança da Informação PL','Analista Digital I',
'Analista Digital III','Analista Experiência Associado JR','Analista Experiência Associado PL','Analista Ouvidoria JR',
'Analista Ouvidoria PL','Analista Ouvidoria SR','Assistente Administrativo','Assistente de Atendimento','Coordenador Central Atend e Negócios',
'Estagiário NS','Ouvidor','Superintendente de Ouvidoria e Compliance','TERCEIRO','Analista de Segurança da Informação JR',
'Analista de Segurança da Informação PL','Superintendente de Operaçoes Produtos')
and cnt.contact_type in (2307,2305)
and a.sym in ('Analista Compliance','Analista Ouvidoria','Analista Segurança','Central de Relacionamento')
