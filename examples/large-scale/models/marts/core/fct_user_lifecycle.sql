with users as (
    select * from {{ ref('stg_users') }}
),

activity as (
    select * from {{ ref('int_user_activity_summary') }}
),

first_events as (
    select * from {{ ref('int_user_first_events') }}
),

final as (
    select
        users.user_id,
        users.status,
        users.created_at as signup_at,
        first_events.first_event_at as activated_at,
        first_events.first_feature_use_at as first_value_at,
        activity.total_sessions,
        activity.total_events,
        case
            when users.status = 'churned' then 'churned'
            when first_events.first_feature_use_at is not null then 'activated'
            when first_events.first_event_at is not null then 'onboarding'
            else 'signed_up'
        end as lifecycle_stage
    from users
    left join activity on users.user_id = activity.user_id
    left join first_events on users.user_id = first_events.user_id
)

select * from final
