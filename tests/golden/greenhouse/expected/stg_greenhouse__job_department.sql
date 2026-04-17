with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_department_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    department_id
    
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
        cast(department_id as TEXT) as department_id,
        cast(job_id as TEXT) as job_id
        
    from fields
)

select * from final
