with users as (
    select * from {{ ref('stg_users') }}
),

first_events as (
    select * from {{ ref('int_user_first_events') }}
),

subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

paid_subs as (
    select distinct account_id
    from subscriptions
    where status = 'active' and monthly_amount > 0
),

final as (
    select
        users.user_id,
        users.signup_source,
        1 as reached_signup,
        case when first_events.first_event_at is not null then 1 else 0 end as reached_activation,
        case when first_events.first_feature_use_at is not null then 1 else 0 end as reached_engagement,
        case when paid_subs.account_id is not null then 1 else 0 end as reached_conversion,
        case
            when paid_subs.account_id is not null then 'converted'
            when first_events.first_feature_use_at is not null then 'engaged'
            when first_events.first_event_at is not null then 'activated'
            else 'signed_up'
        end as current_funnel_stage
    from users
    left join first_events on users.user_id = first_events.user_id
    left join paid_subs on users.account_id = paid_subs.account_id
)

select * from final
