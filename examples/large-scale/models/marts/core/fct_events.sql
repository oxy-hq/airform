with events as (
    select * from {{ ref('stg_events') }}
),

event_types as (
    select * from {{ ref('stg_event_types') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        events.event_id,
        events.user_id,
        events.session_id,
        events.event_type,
        events.event_name,
        event_types.event_category,
        events.properties,
        events.event_timestamp,
        cast(events.event_timestamp as date) as event_date,
        users.account_id
    from events
    left join event_types on events.event_id = event_types.event_id
    left join users on events.user_id = users.user_id
)

select * from final
