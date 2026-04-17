with base as (
    select 
    from "sap"."main_sap"."stg_sap__sapsll_tunos_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    ctsty
    
 , 
    cast(null as TEXT) as 
    
    land1
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    stcts
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        cast(land1 as TEXT) as land1,
        cast(ctsty as TEXT) as ctsty,
        cast(stcts as TEXT) as stcts
    from fields
)

select *
from final
