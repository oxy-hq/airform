with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaigns_tmp"

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
    
    clicktale
    
 , 
    cast(null as TEXT) as 
    
    content_type
    
 , 
    cast(null as timestamp) as 
    
    create_time
    
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
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as TEXT) as 
    
    long_archive_url
    
 , 
    cast(null as TEXT) as 
    
    reply_to
    
 , 
    cast(null as integer) as 
    
    segment_id
    
 , 
    cast(null as integer) as 
    
    segment_text
    
 , 
    cast(null as timestamp) as 
    
    send_time
    
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
    
    test_size
    
 , 
    cast(null as boolean) as 
    
    timewarp
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as TEXT) as 
    
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
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as boolean) as 
    
    use_conversation
    
 , 
    cast(null as integer) as 
    
    wait_time
    
 , 
    cast(null as integer) as 
    
    winner_criteria
    
 , 
    cast(null as integer) as 
    
    winning_campaign_id
    
 , 
    cast(null as integer) as 
    
    winning_combination_id
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as campaign_id,
        segment_id,
        create_time as create_timestamp,
        cast(send_time as timestamp) as send_timestamp, 
        list_id,
        reply_to as reply_to_email,
        type as campaign_type,
        title,
        archive_url,
        authenticate,
        auto_footer,
        auto_tweet,
        clicktale,
        content_type,
        drag_and_drop,
        fb_comments,
        folder_id,
        from_name,
        google_analytics,
        inline_css,
        long_archive_url,
        status,
        subject_line,
        template_id,
        test_size,
        timewarp,
        to_name,
        track_ecomm_360,
        track_goals,
        track_html_clicks,
        track_opens,
        track_text_clicks,
        use_conversation,
        wait_time,
        winner_criteria,
        winning_campaign_id,
        winning_combination_id
    from fields

)

select *
from final
