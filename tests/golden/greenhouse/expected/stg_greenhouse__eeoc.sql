with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__eeoc_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    application_id
    
 , 
    cast(null as TEXT) as 
    
    disability_status_description
    
 , 
    cast(null as integer) as 
    
    disability_status_id
    
 , 
    cast(null as TEXT) as 
    
    gender_description
    
 , 
    cast(null as integer) as 
    
    gender_id
    
 , 
    cast(null as TEXT) as 
    
    race_description
    
 , 
    cast(null as integer) as 
    
    race_id
    
 , 
    cast(null as timestamp) as 
    
    submitted_at
    
 , 
    cast(null as TEXT) as 
    
    veteran_status_description
    
 , 
    cast(null as integer) as 
    
    veteran_status_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

        
    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(application_id as TEXT) as application_id,
        disability_status_description,
        cast(disability_status_id as TEXT) as disability_status_id,
        gender_description,
        cast(gender_id as TEXT) as gender_id,
        race_description,
        cast(race_id as TEXT) as race_id,
        cast(submitted_at as timestamp) as submitted_at,
        veteran_status_description,
        cast(veteran_status_id as TEXT) as veteran_status_id

    from fields
)

select * from final
