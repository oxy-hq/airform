with base as (
    select 
    from "sap"."main_sap"."stg_sap__sapsll_clsnr_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    bemeh
    
 , 
    cast(null as TEXT) as 
    
    ccngn
    
 , 
    cast(null as TEXT) as 
    
    datab
    
 , 
    cast(null as TEXT) as 
    
    datbi
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    nosct
    
 


    from base
),

final as (
    select
        cast(nosct as TEXT) as nosct,
        cast(ccngn as TEXT) as ccngn,
        cast(datab as TEXT) as datab,
        cast(datbi as TEXT) as datbi,
        cast(mandt as TEXT) as mandt,
        cast(bemeh as TEXT) as bemeh
    from fields
)

select *
from final
