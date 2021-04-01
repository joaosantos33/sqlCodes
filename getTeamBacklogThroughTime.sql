DECLARE @dt_ini_convertido AS INTEGER
DECLARE @dt_fim_convertido AS INTEGER

DECLARE @dia as INTEGER
set @dia = 0

DECLARE @momentoQueEstouMedindo as INTEGER

--SET @dt_ini_convertido = DATEDIFF(second,'1969-12-31 21:00:00','2019-01-' + CONVERT(VARCHAR,@dia) + ' 18:00:00')

DECLARE @hora_computada as INTEGER
set @hora_computada = 1564691034

declare @tabela_backlog TABLE(
    qtdTickets INTEGER,
    dia DATETIME
)

declare @initialDate AS DATETIME
set @initialDate = '2019-05-01 18:00:00'


WHILE @dia < 10
    BEGIN

        set @momentoQueEstouMedindo = DATEDIFF(second,'1969-12-31 21:00:00',DATEADD(D,@dia,@initialDate))

        insert into @tabela_backlog
        select count(cv.id) ,
        --cr.ref_num,
        DATEADD(S,@momentoQueEstouMedindo,'1969-12-31 21:00:00') 
        from z_ciclo_vida cv  WITH(nolock)
        join call_req cr WITH(nolock) on cr.persid = cv.z_srl_CallReq
        where 
        cv.z_srl_Grupo = 0x5365FC329764E0458614885F7DBD22D9    
        and cv.z_dat_Inicio < @momentoQueEstouMedindo 
        and (cv.z_dat_Fim > @momentoQueEstouMedindo or cv.z_dat_Fim is null)
        and cr.[type] = 'I' 
        and (cv.z_srl_Status not in ('CL', 'RE','zsolaguavali') or cv.z_srl_Status is null)

        set @dia = @dia + 1

    END

select t.qtdTickets,t.dia from @tabela_backlog t