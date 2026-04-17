with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__candidate_tag_tmp"

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
    
    tag_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

        
    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(candidate_id as TEXT) as candidate_id,
        cast(tag_id as TEXT) as tag_id

    from fields
)

select * from final
