with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__segments_tmp"

),


fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as integer) as 
    
    member_count
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base

), 

final as (

    select
        source_relation,
        id as segment_id,
        list_id,
        member_count,
        name as segment_name,
        type as segment_type,
        updated_at as updated_timestamp,
        created_at as created_timestamp
    from fields

)

select *
from final
