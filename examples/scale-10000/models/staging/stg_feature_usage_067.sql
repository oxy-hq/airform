with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        version
,        platform
,        feature_name
,        first_used_at
,        category
    from source
)
select * from renamed
