with base as (
    select 
    from "sap"."main_sap"."stg_sap__sapsll_maritc_tmp"
),

fields as (
    select
        
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
    
    matnr
    
 , 
    cast(null as TEXT) as 
    
    stcts
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        cast(matnr as TEXT) as matnr,
        cast(stcts as TEXT) as stcts,
        cast(datab as TEXT) as datab,
        cast(datbi as TEXT) as datbi,
        cast(ccngn as TEXT) as ccngn
    from fields
)

select *
from final
