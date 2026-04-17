with  __dbt__cte__int__activities_by_prospect as (
with activities as (

    select *
    from "pardot"."main_stg_pardot"."stg_pardot__visitor_activity"

), visitors as (

    select *
    from "pardot"."main_stg_pardot"."stg_pardot__visitor"

), joined as (

    select
        activities.source_relation,
        activities.event_type_name,
        activities.created_timestamp,
        coalesce(visitors.prospect_id, activities.prospect_id) as prospect_id
    from activities
    left join visitors
        on activities.visitor_id = visitors.visitor_id
        and activities.source_relation = visitors.source_relation

), aggregated as (

    select
        source_relation,
        prospect_id,

        

        count(case when lower(event_type_name) = 'visit' then 1 end) as count_activity_visits,
        max(case when lower(event_type_name) = 'visit' then created_timestamp end) as most_recent_visit_activity_timestamp,
        count(case when lower(event_type_name) = 'email' then 1 end) as count_activity_emails,
        max(case when lower(event_type_name) = 'email' then created_timestamp end) as most_recent_email_activity_timestamp
    from joined
    group by 1, 2

)

select *
from aggregated
), prospects as (

    select *
    from "pardot"."main_stg_pardot"."stg_pardot__prospect"

), activities as (

    select *
    from __dbt__cte__int__activities_by_prospect

), joined as (

    select
        prospects.*,
        

        coalesce(activities.count_activity_visits,0) as count_activity_visits,
        coalesce(activities.count_activity_emails,0) as count_activity_emails,
        activities.most_recent_visit_activity_timestamp,
        activities.most_recent_email_activity_timestamp
    from prospects
    left join activities
        on prospects.prospect_id = activities.prospect_id
        and prospects.source_relation = activities.source_relation

)

select *
from joined
