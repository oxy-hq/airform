with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__interview_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    interview_kit_content
    
 , 
    cast(null as integer) as 
    
    job_stage_id
    
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
        cast(id as TEXT) as interview_id,
        interview_kit_content,
        cast(job_stage_id as TEXT) as job_stage_id,
        name

    from fields
)

select * from final
