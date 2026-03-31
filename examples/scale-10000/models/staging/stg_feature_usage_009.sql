with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        usage_count
,        version
,        is_active
,        first_used_at
,        last_used_at
    from source
)
select * from renamed
