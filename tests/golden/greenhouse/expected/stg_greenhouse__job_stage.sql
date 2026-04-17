with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_stage_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    job_id
    
 , 
    cast(null as TEXT) as 
    
    name
    
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
        cast(created_at as timestamp) as created_at,
        cast(id as TEXT) as job_stage_id,
        cast(job_id as TEXT) as job_id,
        name as stage_name,
        cast(updated_at as timestamp) as last_updated_at

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
