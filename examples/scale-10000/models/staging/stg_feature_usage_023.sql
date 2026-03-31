with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        first_used_at
,        last_used_at
,        is_active
,        user_id
,        category
,        usage_count
    from source
)
select * from renamed
