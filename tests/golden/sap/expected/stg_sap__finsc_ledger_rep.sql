with base as (
    select 
    from "sap"."main_sap"."stg_sap__finsc_ledger_rep_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    rldnr
    
 , 
    cast(null as TEXT) as 
    
    rldnr_pers
    
 


    from base
),

final as (
    select
        cast(rldnr as TEXT) as rldnr,
        cast(mandt as TEXT) as mandt,
        cast(rldnr_pers as TEXT) as rldnr_pers
    from fields
)

select *
from final
