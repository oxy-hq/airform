with  __dbt__cte__int__activities_by_list as (
with prospects as (

    select *
    from "pardot"."main_pardot"."pardot__prospects"

), lists as (

    select *
    from "pardot"."main_stg_pardot"."stg_pardot__list"

), list_membership as (

    select *
    from "pardot"."main_stg_pardot"."stg_pardot__list_membership"

), joined as (

    select
        list_membership.source_relation,
        list_membership.list_id,
        prospects.count_activity_visits,
        prospects.count_activity_emails,
        prospects.most_recent_visit_activity_timestamp,
        prospects.most_recent_email_activity_timestamp
    from list_membership
    left join prospects
        on list_membership.prospect_id = prospects.prospect_id
        and list_membership.source_relation = prospects.source_relation

), aggregated as (

    select
        source_relation,
        list_id,
        sum(count_activity_emails) as count_activity_emails,
        sum(count_activity_visits) as count_activity_visits,
        max(most_recent_email_activity_timestamp) as most_recent_email_activity_timestamp,
        max(most_recent_visit_activity_timestamp) as most_recent_visit_activity_timestamp
    from joined
    group by 1, 2

)

select *
from aggregated
), lists as (

    select *
    from "pardot"."main_stg_pardot"."stg_pardot__list"

), activities as (

    select *
    from __dbt__cte__int__activities_by_list

), joined as (

    select
        lists.*,
        coalesce(activities.count_activity_emails,0) as count_activity_emails,
        coalesce(activities.count_activity_visits,0) as count_activity_visits,
        activities.most_recent_email_activity_timestamp,
        activities.most_recent_visit_activity_timestamp
    from lists
    left join activities
        on lists.list_id = activities.list_id
        and lists.source_relation = activities.source_relation

)

select *
from joined
