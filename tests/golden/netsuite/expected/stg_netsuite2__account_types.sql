with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__account_types_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    balancesheet
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
        
            
            "left"
            
        
    
 , 
    cast(null as TEXT) as 
    
    longname
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation, 
        _fivetran_deleted,
        _fivetran_synced,
        id as account_type_id,
        balancesheet = 'T' as is_balancesheet,left= 'T' as is_leftside,
        longname as type_name

    from fields
)

select *
from final
