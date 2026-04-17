with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_office_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    job_id
    
 , 
    cast(null as integer) as 
    
    office_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(office_id as TEXT) as office_id,
        cast(job_id as TEXT) as job_id

    from fields
)

select * from final
