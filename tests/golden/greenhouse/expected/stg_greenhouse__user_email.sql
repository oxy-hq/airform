with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__user_email_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as integer) as 
    
    user_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        email,
        cast(user_id as TEXT) as user_id
        
    from fields
)

select * from final
