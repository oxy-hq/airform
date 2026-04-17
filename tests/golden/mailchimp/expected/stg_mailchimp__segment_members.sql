with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__segment_members_tmp"

),


fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as TEXT) as 
    
    member_id
    
 , 
    cast(null as integer) as 
    
    segment_id
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base

), 

final as (

    select
        source_relation,
        segment_id,
        member_id,
        list_id
    from fields

)

select *
from final
