--Estrutura padrão de cursor

declare @ticket as varchar(25)

declare tickets cursor for
select cr.persid 
from call_req cr
where
cr.open_date between 1459468800 and 1483228800
and cr.type = 'P'


open tickets 
fetch next from tickets into @ticket
	while @@FETCH_STATUS = 0
		begin
	
	
		fetch next from tickets into @ticket
	end
	

close tickets
deallocate tickets