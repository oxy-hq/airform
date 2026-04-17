with  __dbt__cte__int_mailchimp__automation_recipients as (


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
), activities as (

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
        campaign_id as automation_email_id,
        count(*) as unsubscribes
    from unsubscribes
    group by 1,2


-- aggregate automation opens and clicks by email

), pivoted as (

    select
        source_relation,
        automation_email_id,
        sum(case when action_type = 'open' then 1 end) as opens,
        sum(case when action_type = 'click' then 1 end) as clicks,
        count(distinct case when action_type = 'open' then member_id end) as unique_opens,
        count(distinct case when action_type = 'click' then member_id end) as unique_clicks
    from activities
    group by 1,2

), sends as (

    select
        source_relation,
        automation_email_id,
        count(*) as sends
    from recipients
    group by 1,2

), joined as (

    select
        coalesce(sends.source_relation
            , pivoted.source_relation
            , unsubscribes_xf.source_relation
            ) as source_relation,
        coalesce(sends.automation_email_id
            , pivoted.automation_email_id
            , unsubscribes_xf.automation_email_id
            ) as automation_email_id,
        pivoted.opens,
        pivoted.clicks,
        pivoted.unique_opens,
        pivoted.unique_clicks,
        sends.sends
        , unsubscribes_xf.unsubscribes
    from sends
    left join pivoted
        on pivoted.automation_email_id = sends.automation_email_id
        and pivoted.source_relation = sends.source_relation

    
    left join unsubscribes_xf
        on unsubscribes_xf.automation_email_id = sends.automation_email_id
        and unsubscribes_xf.source_relation = sends.source_relation
    
)

select *
from joined
