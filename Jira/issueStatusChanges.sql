select CONCAT(P.pkey, '-', CAST(I.issuenum AS VARCHAR)) as Key
     , cg.created
     , u.display_name
     , ci.newstring
     , ci.oldstring
from jiraissue i
         join project p on p.id = i.project
         join changegroup cg on cg.issueid = i.id
         join changeitem ci on ci.groupid = cg.id
         join cwd_user u on u.user_name = cg.author
where i.issuenum = 40845
order by ci.id desc;
