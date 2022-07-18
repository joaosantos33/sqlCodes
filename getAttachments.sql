declare @ticket as varchar(30)

set @ticket = '16817572'

select  distinct concat(r.upload_path,'/', a.rel_file_path)
from call_req cr
join usp_lrel_attachments_requests lrel on lrel.cr = cr.persid
join attmnt a on a.id = lrel.attmnt
join doc_rep r on r.persid = a.repository
where ref_num = @ticket
