with base as (
    select 
    from "sap"."main_sap"."stg_sap__finsc_ld_cmp_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    curposb
    
 , 
    cast(null as TEXT) as 
    
    curposc
    
 , 
    cast(null as TEXT) as 
    
    curposd
    
 , 
    cast(null as TEXT) as 
    
    curpose
    
 , 
    cast(null as TEXT) as 
    
    curposf
    
 , 
    cast(null as TEXT) as 
    
    curposg
    
 , 
    cast(null as TEXT) as 
    
    curposk
    
 , 
    cast(null as TEXT) as 
    
    curposo
    
 , 
    cast(null as TEXT) as 
    
    curposv
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    rldnr
    
 


    from base
),

final as (
    select
        curposk,
        curposo,
        curposv,
        curposb,
        curposc,
        curposd,
        curpose,
        curposf,
        curposg,
        cast(mandt as TEXT) as mandt,
        cast(bukrs as TEXT) as bukrs,
        cast(rldnr as TEXT) as rldnr
    from fields
)

select *
from final
