SELECT cnt.last_name as 'Nome', cnt.userid as 'Login', 
(
SELECT TOP 1 dept.name
FROM grpmem gm
JOIN ca_contact grp ON grp.contact_uuid = gm.group_id
JOIN ca_resource_department dept ON dept.id = grp.department
WHERE
gm.member = cnt.contact_uuid
and dept.name not like 'aprova%'
) as 'Área',r.name as 'Perfil',
(
SELECT dbo.z_retorna_data(e2.log_time)
FROM event_log e2
WHERE
e2.id = (
	SELECT MIN(e.id)
	FROM event_log e
	JOIN session_log s ON s.id = e.session_id
	WHERE
	s.contact = cnt.contact_uuid
)
) as 'Data Criação',
GETDATE() 'Horário da Execução'
FROM usp_cnt_role cr
JOIN ca_contact cnt ON cnt.contact_uuid = cr.contact
JOIN usp_contact u ON u.contact_uuid = cnt.contact_uuid
JOIN usp_role r ON r.id = cr.role_obj
WHERE
--cr.role_obj = 400035--perfil adm mudança
cr.role_obj = 10002 --código do perfil administrador 
--cr.role_obj = 400033--código do perfil adm cadastro
and cnt.inactive = 0 --apenas usuários ativos
ORDER BY cnt.last_name
