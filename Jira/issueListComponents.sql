SELECT concat(p.pkey,'-',j.issuenum) Ticket,
       j.reporter usuario, j.assignee analista,
       j.summary Resumo, j.description descricao, c.cname Componente, j.created
FROM jiraissue j,
     nodeassociation n,
     component c,
     project p
WHERE n.association_type = 'IssueComponent'
AND p.id = j.project
AND n.sink_node_id = c.id
AND j.id = n.source_node_id
AND p.pkey = 'SD'
AND j.created > timestamp '2022-09-19 00:00:00'
order by j.created;
