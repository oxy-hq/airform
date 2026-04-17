with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_post_tmp"

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
    
    content
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as boolean) as 
    
    external
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    internal
    
 , 
    cast(null as TEXT) as 
    
    internal_content
    
 , 
    cast(null as integer) as 
    
    job_id
    
 , 
    cast(null as boolean) as 
    
    live
    
 , 
    cast(null as TEXT) as 
    
    location_name
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        content,
        cast(created_at as timestamp) as created_at,
        external as is_external,
        cast(id as TEXT) as job_post_id,
        internal as is_internal,
        internal_content,
        cast(job_id as TEXT) as job_id,
        live as is_live,
        location_name,
        title,
        cast(updated_at as timestamp) as last_updated_at

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
