with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id,
        user_id,
        feature_name,
        used_at,
        usage_count,
        duration_seconds
    from source
)

select * from renamed
