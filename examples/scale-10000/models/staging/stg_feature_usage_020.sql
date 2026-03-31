with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        feature_name
,        first_used_at
,        usage_count
,        version
,        last_used_at
,        platform
    from source
)
select * from renamed
