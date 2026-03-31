with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

final as (
    select
        id as feature_usage_id,
        user_id,
        feature_name,
        case
            when feature_name in ('dashboard', 'reports') then 'analytics'
            when feature_name in ('api', 'webhooks') then 'developer'
            when feature_name in ('team_management', 'settings') then 'admin'
            when feature_name in ('export_csv') then 'data'
            else 'other'
        end as feature_category,
        usage_count,
        used_at
    from source
)

select * from final
