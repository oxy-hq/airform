with unpivot_gl as ( 

	select * 
	from "sap"."main_sap"."int_sap__0fi_gl_10_unpivot"
),

final as (

    select 
        ryear,
        activ,
        rmvct,
        rtcur,
        runit,
        awtyp,
        rldnr,
        rrcty,
        rvers,
        logsys,
        racct,
        cost_elem,
        rbukrs,
        rcntr,
        prctr,
        rfarea,
        rbusa,
        kokrs,
        segment,
        scntr,
        pprctr,
        sfarea,
        sbusa,
        rassc,
        psegment,
        faglflext_timestamp,
        currency_type,
        fiscal_period,
        sum(debit_amount) as debit_amount,
        sum(credit_amount) as credit_amount,
        sum(accumulated_balance) as accumulated_balance,
        sum(turnover) as turnover
    from unpivot_gl
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28  
)

select * 
from final
