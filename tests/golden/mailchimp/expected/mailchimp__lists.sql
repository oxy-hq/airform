with  __dbt__cte__int_mailchimp__campaign_activities_by_list as (
with recipients as (

    select *
    from "mailchimp"."main_mailchimp"."mailchimp__campaign_recipients"

), pivoted as (

    select
        source_relation,
        list_id,
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
),  __dbt__cte__int_mailchimp__members_by_list as (
with members as (

    select *
    from "mailchimp"."main_mailchimp"."mailchimp__members"

), by_list as (

    select
        source_relation,
        list_id,
        count(*) as count_members,
        max(signup_timestamp) as most_recent_signup_timestamp
    from members
    group by 1,2

)

select *
from by_list
),  __dbt__cte__int_mailchimp__automation_recipients as (


with recipients as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_recipients"

), automation_emails as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_emails"

), automations as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automations"

), joined as (

    select
        recipients.*,
        automations.segment_id,
        automations.automation_id

    from recipients
    left join automation_emails
        on recipients.automation_email_id = automation_emails.automation_email_id
        and recipients.source_relation = automation_emails.source_relation
    left join automations
        on automation_emails.automation_id = automations.automation_id
        and automation_emails.source_relation = automations.source_relation

)

select * 
from joined
),  __dbt__cte__int_mailchimp__automation_unsubscribes as (


with unsubscribes as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__unsubscribes"

), automation_emails as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_emails"

), automations as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automations"

), joined as (

    select
        unsubscribes.*,
        automations.segment_id,
        automations.automation_id

    from unsubscribes
    left join automation_emails
        on unsubscribes.campaign_id = automation_emails.automation_email_id
        and unsubscribes.source_relation = automation_emails.source_relation
    left join automations
        on automation_emails.automation_id = automations.automation_id
        and automation_emails.source_relation = automations.source_relation

)

select * 
from joined
),  __dbt__cte__int_mailchimp__automation_activities_by_list as (


with activities as (

    select *
    from "mailchimp"."main_mailchimp"."mailchimp__automation_activities"

), recipients as (

    select *
    from __dbt__cte__int_mailchimp__automation_recipients


), unsubscribes as (

    select *
    from __dbt__cte__int_mailchimp__automation_unsubscribes

), unsubscribes_xf as (

    select
        source_relation,
        list_id,
        count(*) as unsubscribes
    from unsubscribes
    group by 1,2


-- aggregate automation opens and clicks by list

), pivoted as (

    select
        source_relation,
        list_id,
        sum(case when action_type = 'open' then 1 end) as opens,
        sum(case when action_type = 'click' then 1 end) as clicks,
        count(distinct case when action_type = 'open' then member_id end) as unique_opens,
        count(distinct case when action_type = 'click' then member_id end) as unique_clicks
    from activities
    group by 1,2

), sends as (

    select
        source_relation,
        list_id,
        count(*) as sends
    from recipients
    group by 1,2

), joined as (

    select
        coalesce(sends.source_relation
            , pivoted.source_relation
            , unsubscribes_xf.source_relation
            ) as source_relation,
        coalesce(sends.list_id
            , pivoted.list_id
            , unsubscribes_xf.list_id
            ) as list_id,
        pivoted.opens,
        pivoted.clicks,
        pivoted.unique_opens,
        pivoted.unique_clicks,
        sends.sends
        , unsubscribes_xf.unsubscribes
    from sends
    left join pivoted
        on pivoted.list_id = sends.list_id
        and pivoted.source_relation = sends.source_relation

    
    left join unsubscribes_xf
        on unsubscribes_xf.list_id = sends.list_id
        and unsubscribes_xf.source_relation = sends.source_relation
    
)

select *
from joined
), lists as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__lists"

), campaign_activities as (

    select *
    from __dbt__cte__int_mailchimp__campaign_activities_by_list

), members as (

    select *
    from __dbt__cte__int_mailchimp__members_by_list

), members_xf as (

    select
        lists.*,
        coalesce(members.count_members,0) as count_members,
        members.most_recent_signup_timestamp
    from lists
    left join members
        on lists.list_id = members.list_id
        and lists.source_relation = members.source_relation

), metrics as (

    select
        members_xf.*,
        coalesce(campaign_activities.sends,0) as campaign_sends,
        coalesce(campaign_activities.opens,0) as campaign_opens,
        coalesce(campaign_activities.clicks,0) as campaign_clicks,
        coalesce(campaign_activities.unique_opens,0) as campaign_unique_opens,
        coalesce(campaign_activities.unique_clicks,0) as campaign_unique_clicks

        
        , coalesce(campaign_activities.unsubscribes,0) as campaign_unsubscribes
        
    from members_xf
    left join campaign_activities
        on members_xf.list_id = campaign_activities.list_id
        and members_xf.source_relation = campaign_activities.source_relation



), automation_activities as (

    select *
    from __dbt__cte__int_mailchimp__automation_activities_by_list

), metrics_xf as (

    select
        metrics.*,
        coalesce(automation_activities.sends,0) as automation_sends,
        coalesce(automation_activities.opens,0) as automation_opens,
        coalesce(automation_activities.clicks,0) as automation_clicks,
        coalesce(automation_activities.unique_opens,0) as automation_unique_opens,
        coalesce(automation_activities.unique_clicks,0) as automation_unique_clicks

        
        , coalesce(automation_activities.unsubscribes,0) as automation_unsubscribes
        
    from metrics
    left join automation_activities
        on metrics.list_id = automation_activities.list_id
        and metrics.source_relation = automation_activities.source_relation

)

select *
from metrics_xf
