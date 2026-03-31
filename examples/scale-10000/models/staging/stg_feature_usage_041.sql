with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        first_used_at
,        version
,        feature_name
,        is_active
    from source
)
select * from renamed
