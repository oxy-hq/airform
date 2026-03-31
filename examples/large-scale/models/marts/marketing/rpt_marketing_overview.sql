with users as (
    select * from {{ ref('stg_users') }}
),

first_events as (
    select * from {{ ref('int_user_first_events') }}
),

final as (
    select
        users.signup_source,
        count(distinct users.user_id) as total_signups,
        count(distinct case when users.status = 'active' then users.user_id end) as active_users,
        count(distinct case when users.status = 'churned' then users.user_id end) as churned_users,
        count(distinct case when first_events.first_event_at is not null then users.user_id end) as activated_users,
        count(distinct case when first_events.first_feature_use_at is not null then users.user_id end) as engaged_users,
        case
            when count(distinct users.user_id) > 0
            then cast(count(distinct case when first_events.first_event_at is not null then users.user_id end) as float)
                / cast(count(distinct users.user_id) as float)
            else 0
        end as activation_rate
    from users
    left join first_events on users.user_id = first_events.user_id
    group by users.signup_source
)

select * from final
