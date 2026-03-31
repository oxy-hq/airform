with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        user_id
,        feature_name
,        last_used_at
,        platform
,        first_used_at
    from source
)
select * from renamed
