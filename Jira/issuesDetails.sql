SELECT
    --Issue
    I.id                                             AS "issue_id",
    CONCAT(P.pkey, '-', CAST(I.issuenum AS VARCHAR)) AS "issue_key",
    rt.stringvalue                                   AS "request_type",
    I.summary                                        AS "issue_summary",
    I.assignee                                       AS "issue_assignee",
    I.creator                                        AS "issue_creator",
    I.created                                        AS "issue_creation_date",
    I.description                                    AS "issue_description",
    I.reporter                                       AS "issue_reporter",
    I.updated                                        AS "issue_last_updated_date",
    --Resolution
    R.id                                             AS "resolution_id",
    R.pname                                          AS "resolution_name",
    I.resolutiondate                                 AS "resolution_date",
    --Project
    P.id                                             AS "project_id",
    P.pname                                          AS "project_name",
    P.pkey                                           AS "project_key",
    PC.cname                                         AS "project_category_name",
    PC.description                                   AS "project_category_description",
    --Issue Type
    IT.id                                            AS "issue_type_id",
    IT.pname                                         AS "issue_type_name",
    --Issue Status
    ISS.id                                           AS "issue_status_id",
    ISS.pname                                        AS "issue_status_name",
    ISS.statuscategory                               AS "issue_status_category"
FROM jiraissue I
         JOIN project P
              ON P.id = I.project
         LEFT JOIN nodeassociation N
                   ON N.association_type = 'ProjectCategory'
                       AND N.source_node_id = P.id
         LEFT JOIN projectcategory PC
                   ON N.association_type = 'ProjectCategory'
                       AND PC.id = N.sink_node_id
         JOIN issuetype IT
              ON IT.id = I.issuetype
         JOIN issuestatus ISS
              ON ISS.id = I.issuestatus
         LEFT JOIN resolution R
                   ON R.id = I.resolution
         LEFT JOIN customfieldvalue rt on i.id = rt.issue and rt.customfield = 1720


WHERE P.pkey = 'SD'
order by i.id desc;

