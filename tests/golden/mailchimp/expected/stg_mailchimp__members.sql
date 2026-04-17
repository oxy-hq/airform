with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__members_tmp"

),


fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    country_code
    
 , 
    cast(null as float) as 
    
    dstoff
    
 , 
    cast(null as TEXT) as 
    
    email_address
    
 , 
    cast(null as TEXT) as 
    
    email_client
    
 , 
    cast(null as TEXT) as 
    
    email_type
    
 , 
    cast(null as float) as 
    
    gmtoff
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    ip_opt
    
 , 
    cast(null as TEXT) as 
    
    ip_signup
    
 , 
    cast(null as TEXT) as 
    
    language
    
 , 
    cast(null as timestamp) as 
    
    last_changed
    
 , 
    cast(null as float) as 
    
    latitude
    
 , 
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as float) as 
    
    longitude
    
 , 
    cast(null as integer) as 
    
    member_rating
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as timestamp) as 
    
    timestamp_opt
    
 , 
    cast(null as timestamp) as 
    
    timestamp_signup
    
 , 
    cast(null as TEXT) as 
    
    timezone
    
 , 
    cast(null as TEXT) as 
    
    unique_email_id
    
 , 
    cast(null as boolean) as 
    
    vip
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as member_id,
        email_address,
        email_client,
        email_type,
        status,
        list_id,
        timestamp_signup as signup_timestamp,
        timestamp_opt as opt_in_timestamp,
        last_changed as last_changed_timestamp,
        country_code,
        dstoff,
        gmtoff,
        ip_opt as opt_in_ip_address,
        ip_signup as signup_ip_address,
        language,
        latitude,
        longitude,
        member_rating,
        timezone,
        unique_email_id,
        vip
        
        --The below macro adds the fields defined within your mailchimp__member_pass_through_columns variable into the staging model
        




        
    from fields

)

select *
from final
