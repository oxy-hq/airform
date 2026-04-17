with __dbt__cte__int_greenhouse__user_emails as (
with user_email as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__user_email"
),

greenhouse_user as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__user"
),

agg_emails as (

    select
        source_relation,
        user_id,
        
    string_agg(email, ', ')

 as email

    from user_email

    group by 1, 2
),

final as (

    select
        greenhouse_user.*,
        agg_emails.email
    from greenhouse_user
    left join agg_emails
        on greenhouse_user.user_id = agg_emails.user_id
        and greenhouse_user.source_relation = agg_emails.source_relation
)

select * 
from final
),  __dbt__cte__int_greenhouse__application_users as (
with greenhouse_user as (

    select *
    from __dbt__cte__int_greenhouse__user_emails
),

application as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__application"
),

-- necessary users = credited_to_user (ie referrer), prospect_owner
join_user_names as (

    select
        application.*,
        referrer.full_name as referrer_name,
        prospect_owner.full_name as prospect_owner_name

    from application

    left join greenhouse_user as referrer
        on application.credited_to_user_id = referrer.user_id
        and application.source_relation = referrer.source_relation
    left join greenhouse_user as prospect_owner
        on application.prospect_owner_user_id = prospect_owner.user_id
        and application.source_relation = prospect_owner.source_relation

)

select *
from join_user_names
) select application_id
from __dbt__cte__int_greenhouse__application_users
where application_id is null
