with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        last_used_at
,        first_used_at
,        is_active
,        usage_count
,        feature_name
,        version
    from source
)
select * from renamed
