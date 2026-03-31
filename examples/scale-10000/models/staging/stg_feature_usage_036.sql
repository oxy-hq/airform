with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        user_id
,        last_used_at
,        platform
,        usage_count
    from source
)
select * from renamed
