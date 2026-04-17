with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_opening_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    application_id
    
 , 
    cast(null as integer) as 
    
    close_reason_id
    
 , 
    cast(null as timestamp) as 
    
    closed_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    job_id
    
 , 
    cast(null as timestamp) as 
    
    opened_at
    
 , 
    cast(null as TEXT) as 
    
    opening_id
    
 , 
    cast(null as TEXT) as 
    
    status
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(application_id as TEXT) as application_id,
        cast(close_reason_id as TEXT) as close_reason_id,
        cast(closed_at as timestamp) as closed_at,
        cast(id as TEXT)as job_openining_id,
        cast(job_id as TEXT) as job_id,
        cast(opened_at as timestamp) as opened_at,
        cast(opening_id as TEXT)as opening_text_id,
        status as current_status

    from fields
)

select * from final
