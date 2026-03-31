with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        version
,        category
,        platform
,        is_active
,        usage_count
,        last_used_at
    from source
)
select * from renamed
