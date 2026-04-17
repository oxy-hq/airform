with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__lists_tmp"

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
    
    beamer_address
    
 , 
    cast(null as TEXT) as 
    
    contact_address_1
    
 , 
    cast(null as integer) as 
    
    contact_address_2
    
 , 
    cast(null as TEXT) as 
    
    contact_city
    
 , 
    cast(null as TEXT) as 
    
    contact_company
    
 , 
    cast(null as TEXT) as 
    
    contact_country
    
 , 
    cast(null as TEXT) as 
    
    contact_state
    
 , 
    cast(null as TEXT) as 
    
    contact_zip
    
 , 
    cast(null as timestamp) as 
    
    date_created
    
 , 
    cast(null as TEXT) as 
    
    default_from_email
    
 , 
    cast(null as TEXT) as 
    
    default_from_name
    
 , 
    cast(null as TEXT) as 
    
    default_language
    
 , 
    cast(null as integer) as 
    
    default_subject
    
 , 
    cast(null as boolean) as 
    
    email_type_option
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as float) as 
    
    list_rating
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    notify_on_subscribe
    
 , 
    cast(null as integer) as 
    
    notify_on_unsubscribe
    
 , 
    cast(null as TEXT) as 
    
    permission_reminder
    
 , 
    cast(null as TEXT) as 
    
    subscribe_url_long
    
 , 
    cast(null as TEXT) as 
    
    subscribe_url_short
    
 , 
    cast(null as boolean) as 
    
    use_archive_bar
    
 , 
    cast(null as TEXT) as 
    
    visibility
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base

), 

final as (

    select
        source_relation,
        id as list_id,
        date_created,
        name,
        list_rating,
        beamer_address,
        contact_address_1,
        contact_address_2,
        contact_city,
        contact_company,
        contact_country,
        contact_state,
        contact_zip,
        default_from_email,
        default_from_name,
        default_language,
        default_subject,
        email_type_option,
        notify_on_subscribe,
        notify_on_unsubscribe,
        permission_reminder,
        subscribe_url_long,
        subscribe_url_short,
        use_archive_bar,
        visibility
    from fields

)

select *
from final
