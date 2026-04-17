with activities as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaign_activities"

), campaigns as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaigns"

), since_send as (

    select
        activities.*,
        campaigns.send_timestamp,
        date_diff('minute', campaigns.send_timestamp::timestamp, activities.activity_timestamp::timestamp ) as time_since_send_minutes,
        date_diff('hour', campaigns.send_timestamp::timestamp, activities.activity_timestamp::timestamp ) as time_since_send_hours,
        date_diff('day', campaigns.send_timestamp::timestamp, activities.activity_timestamp::timestamp ) as time_since_send_days
    from activities
    left join campaigns
        on activities.campaign_id = campaigns.campaign_id
        and activities.source_relation = campaigns.source_relation

)

select *
from since_send
