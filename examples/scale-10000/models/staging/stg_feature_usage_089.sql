with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        feature_name
,        platform
,        usage_count
,        last_used_at
,        user_id
    from source
)
select * from renamed
