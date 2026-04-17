with  __dbt__cte__int_mailchimp__campaign_activities_by_campaign as (
with recipients as (

    select *
    from "mailchimp"."main_mailchimp"."mailchimp__campaign_recipients"

), pivoted as (

    select
        source_relation,
        campaign_id,
        count(*) as sends,
        sum(opens) as opens,
        sum(clicks) as clicks,
        count(distinct case when was_opened = True then member_id end) as unique_opens,
        count(distinct case when was_clicked = True then member_id end) as unique_clicks

        
        , count(distinct case when was_unsubscribed = True then member_id end) as unsubscribes
        
    from recipients
    group by 1,2

)

select *
from pivoted
), campaigns as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaigns"

), activities as (

    select *
    from __dbt__cte__int_mailchimp__campaign_activities_by_campaign

), joined as (

    select
        campaigns.*,
        coalesce(activities.sends,0) as sends,
        coalesce(activities.opens,0) as opens,
        coalesce(activities.clicks,0) as clicks,
        coalesce(activities.unique_opens,0) as unique_opens,
        coalesce(activities.unique_clicks,0) as unique_clicks

        
        , coalesce(activities.unsubscribes,0) as unsubscribes
        
    from campaigns
    left join activities
        on campaigns.campaign_id = activities.campaign_id
        and campaigns.source_relation = activities.source_relation

)

select *
from joined
