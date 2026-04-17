with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_application_tmp"

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
    
    job_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(application_id as TEXT) as application_id,
        cast(job_id as TEXT) as job_id
    from fields
)

select * from final
