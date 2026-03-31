with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        usage_count
,        user_id
,        is_active
,        first_used_at
,        version
,        last_used_at
,        platform
    from source
)
select * from renamed
