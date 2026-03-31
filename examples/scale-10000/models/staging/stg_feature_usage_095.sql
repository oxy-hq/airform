with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        platform
,        feature_name
,        user_id
,        version
    from source
)
select * from renamed
