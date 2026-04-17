with base as (
    select 
    from "sap"."main_sap"."stg_sap__sapsll_nosca_tmp"
),

fields as (
    select
        
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
    
 , 
    cast(null as TEXT) as 
    
    stcts
    
 


    from base
),

final as (
    select
        cast(stcts as TEXT) as stcts,
        cast(datab as TEXT) as datab,
        cast(datbi as TEXT) as datbi,
        cast(mandt as TEXT) as mandt,
        cast(nosct as TEXT) as nosct
    from fields
)

select *
from final
