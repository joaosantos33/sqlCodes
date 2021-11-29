select
    CONCAT(P.pkey, '-', CAST(I.issuenum AS VARCHAR)) as Key
,   u.display_name as Analyst
,   ja.created as Date
,   ja.actionbody as Comment

from jiraissue i
join project p on p.id = i.project
join jiraaction ja on ja.issueid = i.id
join cwd_user u on u.user_name = ja.author
where
i.issuenum = 40845
order by i.id desc
limit 10