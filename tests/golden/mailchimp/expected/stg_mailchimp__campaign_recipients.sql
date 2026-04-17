with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaign_recipients_tmp"

),


fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    campaign_id
    
 , 
    cast(null as integer) as 
    
    combination_id
    
 , 
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as TEXT) as 
    
    member_id
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base
),

final as (

    select
        source_relation,
        campaign_id,
        member_id,
        combination_id,
        list_id
    from fields

),

unique_key as (

    select
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(campaign_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(member_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as email_id
    from final

)

select *
from unique_key
