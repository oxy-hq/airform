with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__vendor_categories_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as vendor_category_id,
        name,
        _fivetran_synced
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
