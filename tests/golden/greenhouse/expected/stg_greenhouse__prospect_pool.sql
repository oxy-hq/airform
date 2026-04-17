with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__prospect_pool_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    active
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        active as is_active,
        cast(id as TEXT) as prospect_pool_id,
        name as prospect_pool_name

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
