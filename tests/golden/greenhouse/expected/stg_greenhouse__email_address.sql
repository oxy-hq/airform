with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__email_address_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    candidate_id
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as TEXT) as 
    
    value
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

        
    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(candidate_id as TEXT) as candidate_id,
        index,
        type,
        value as email

    from fields
)

select * from final
