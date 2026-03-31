with users as (
    select * from {{ ref('stg_users') }}
),

first_events as (
    select * from {{ ref('int_user_first_events') }}
),

final as (
    select
        users.user_id,
        users.signup_source,
        users.created_at as signup_at,
        first_events.first_event_at as activation_at,
        first_events.first_feature_use_at,
        case
            when first_events.first_event_at is not null then 1
            else 0
        end as is_activated,
        case
            when first_events.first_feature_use_at is not null then 1
            else 0
        end as has_used_feature
    from users
    left join first_events on users.user_id = first_events.user_id
)

select * from final
