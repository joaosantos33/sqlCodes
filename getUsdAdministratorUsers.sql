SELECT cnt.last_name as 'Nome', cnt.userid as 'Login', r.name as 'Perfil', u.zcargo as 'Cargo', GETDATE() 'Horário da Execução'
FROM usp_cnt_role cr
JOIN ca_contact cnt ON cnt.contact_uuid = cr.contact
JOIN usp_contact u ON u.contact_uuid = cnt.contact_uuid
JOIN usp_role r ON r.id = cr.role_obj
WHERE
cr.role_obj = 10002 --código do perfil administrador
and cnt.inactive = 0 --apenas usuários ativos
ORDER BY cnt.last_name
