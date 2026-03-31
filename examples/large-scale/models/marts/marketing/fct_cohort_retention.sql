with cohorts as (
    select * from {{ ref('int_user_signup_cohorts') }}
),

activity as (
    select * from {{ ref('int_user_activity_summary') }}
),

final as (
    select
        cohorts.signup_quarter,
        count(distinct cohorts.user_id) as cohort_size,
        count(distinct case when activity.total_sessions > 0 then cohorts.user_id end) as users_with_sessions,
        count(distinct case when activity.total_events > 5 then cohorts.user_id end) as engaged_users,
        count(distinct case when cohorts.status = 'active' then cohorts.user_id end) as active_users,
        count(distinct case when cohorts.status = 'churned' then cohorts.user_id end) as churned_users
    from cohorts
    left join activity on cohorts.user_id = activity.user_id
    group by cohorts.signup_quarter
)

select * from final
