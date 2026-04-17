with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__source_tmp"

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
    
 , 
    cast(null as integer) as 
    
    source_type_id
    
 , 
    cast(null as TEXT) as 
    
    source_type_name
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(id as TEXT) as source_id,
        name as source_name,
        cast(source_type_id as TEXT) as source_type_id,
        source_type_name

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
