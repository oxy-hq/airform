with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        is_active
,        version
,        user_id
,        platform
    from source
)
select * from renamed
