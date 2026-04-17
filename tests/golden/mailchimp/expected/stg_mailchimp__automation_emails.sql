with base as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_emails_tmp"

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
    
    archive_url
    
 , 
    cast(null as boolean) as 
    
    authenticate
    
 , 
    cast(null as boolean) as 
    
    auto_footer
    
 , 
    cast(null as boolean) as 
    
    auto_tweet
    
 , 
    cast(null as TEXT) as 
    
    automation_id
    
 , 
    cast(null as integer) as 
    
    clicktale
    
 , 
    cast(null as TEXT) as 
    
    content_type
    
 , 
    cast(null as timestamp) as 
    
    create_time
    
 , 
    cast(null as TEXT) as 
    
    delay_action
    
 , 
    cast(null as TEXT) as 
    
    delay_action_description
    
 , 
    cast(null as integer) as 
    
    delay_amount
    
 , 
    cast(null as integer) as 
    
    delay_direction
    
 , 
    cast(null as TEXT) as 
    
    delay_full_description
    
 , 
    cast(null as TEXT) as 
    
    delay_type
    
 , 
    cast(null as boolean) as 
    
    drag_and_drop
    
 , 
    cast(null as boolean) as 
    
    fb_comments
    
 , 
    cast(null as integer) as 
    
    folder_id
    
 , 
    cast(null as TEXT) as 
    
    from_name
    
 , 
    cast(null as TEXT) as 
    
    google_analytics
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    inline_css
    
 , 
    cast(null as integer) as 
    
    position
    
 , 
    cast(null as TEXT) as 
    
    reply_to
    
 , 
    cast(null as timestamp) as 
    
    send_time
    
 , 
    cast(null as timestamp) as 
    
    start_time
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    subject_line
    
 , 
    cast(null as integer) as 
    
    template_id
    
 , 
    cast(null as integer) as 
    
    timewarp
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as integer) as 
    
    to_name
    
 , 
    cast(null as boolean) as 
    
    track_ecomm_360
    
 , 
    cast(null as boolean) as 
    
    track_goals
    
 , 
    cast(null as boolean) as 
    
    track_html_clicks
    
 , 
    cast(null as boolean) as 
    
    track_opens
    
 , 
    cast(null as boolean) as 
    
    track_text_clicks
    
 , 
    cast(null as integer) as 
    
    use_conversation
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base

), 

final as (

    select
        source_relation,
        -- IDs and standard timestamp
        id as automation_email_id,
        automation_id,
        create_time as created_timestamp,
        start_time as started_timestamp,
        send_time as send_timestamp,

        -- email details
        from_name,
        reply_to,
        status,
        subject_line,
        title,
        to_name,

        archive_url,
        authenticate,
        auto_footer,
        auto_tweet,
        clicktale,
        content_type,
        delay_action,
        delay_action_description,
        delay_amount,
        delay_direction,
        delay_full_description,
        delay_type,
        drag_and_drop,
        fb_comments,
        folder_id,
        google_analytics,
        inline_css,
        position,
        template_id,
        timewarp,
        track_ecomm_360,
        track_goals,
        track_html_clicks,
        track_opens,
        track_text_clicks,
        use_conversation
    from fields

)

select *
from final
