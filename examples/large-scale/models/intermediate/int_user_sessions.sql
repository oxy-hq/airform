with sessions as (
    select * from {{ ref('stg_sessions') }}
),

final as (
    select
        user_id,
        count(*) as total_sessions,
        min(started_at) as first_session_at,
        max(started_at) as last_session_at,
        count(distinct device_type) as distinct_devices,
        sum(case when device_type = 'mobile' then 1 else 0 end) as mobile_sessions,
        sum(case when device_type = 'desktop' then 1 else 0 end) as desktop_sessions
    from sessions
    group by user_id
)

select * from final
