with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__application_history_tmp"

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
    
    new_stage_id
    
 , 
    cast(null as TEXT) as 
    
    new_status
    
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
        cast(application_id as TEXT) as application_id,
        cast(new_stage_id as TEXT) as new_stage_id,
        new_status,
        cast(updated_at as timestamp) as updated_at

    from fields
)

select * from final
