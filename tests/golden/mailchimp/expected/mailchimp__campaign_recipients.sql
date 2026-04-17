with  __dbt__cte__int_mailchimp__campaign_activities_by_email as (
with activities as (

    select *
    from "mailchimp"."main_mailchimp"."mailchimp__campaign_activities"

), pivoted as (

    select
        source_relation,
        email_id,
        sum(case when action_type = 'open' then 1 end) as opens,
        sum(case when action_type = 'click' then 1 end) as clicks,
        count(distinct case when action_type = 'open' then member_id end) as unique_opens,
        count(distinct case when action_type = 'click' then member_id end) as unique_clicks,
        min(case when action_type = 'open' then activity_timestamp end) as first_open_timestamp,
        min(case when action_type = 'open' then time_since_send_minutes end) as time_to_open_minutes,
        min(case when action_type = 'open' then time_since_send_hours end) as time_to_open_hours,
        min(case when action_type = 'open' then time_since_send_days end) as time_to_open_days
    from activities
    group by 1,2

), booleans as (

    select 
        *,
        case when opens > 0 then True else False end as was_opened,
        case when clicks > 0 then True else False end as was_clicked
    from pivoted

)

select *
from booleans
), recipients as (
    
    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaign_recipients"

), activities as (

    select *
    from __dbt__cte__int_mailchimp__campaign_activities_by_email


), unsubscribes as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__unsubscribes"

), unsubscribes_xf as (

    select
        source_relation,
        member_id,
        list_id,
        campaign_id
    from unsubscribes
    group by 1,2,3,4


), campaigns as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaigns"

), joined as (

    select
        recipients.*,
        campaigns.segment_id,
        campaigns.send_timestamp
    from recipients
    left join campaigns
        on recipients.campaign_id = campaigns.campaign_id
        and recipients.source_relation = campaigns.source_relation

), metrics as (

    select
        joined.*,
        coalesce(activities.opens,0) as opens,
        coalesce(activities.unique_opens,0) as unique_opens,
        coalesce(activities.clicks,0) as clicks,
        coalesce(activities.unique_clicks,0) as unique_clicks,
        coalesce(activities.was_opened, False) as was_opened,
        coalesce(activities.was_clicked, False) as was_clicked,
        activities.first_open_timestamp,
        activities.time_to_open_minutes,
        activities.time_to_open_hours,
        activities.time_to_open_days
    from joined
    left join activities
        on joined.email_id = activities.email_id
        and joined.source_relation = activities.source_relation

), metrics_xf as (

    select 
        metrics.*
        
        
        , case when unsubscribes_xf.member_id is not null then True else False end as was_unsubscribed
        
    from metrics

    
    left join unsubscribes_xf
        on metrics.member_id = unsubscribes_xf.member_id
        and metrics.campaign_id = unsubscribes_xf.campaign_id
        and metrics.list_id = unsubscribes_xf.list_id
        and metrics.source_relation = unsubscribes_xf.source_relation
    
)

select * 
from metrics_xf
