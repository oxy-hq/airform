with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__tag_tmp"

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
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(id as TEXT) as tag_id,
        name as tag_name

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
