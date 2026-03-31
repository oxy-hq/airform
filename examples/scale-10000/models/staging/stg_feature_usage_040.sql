with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        category
,        last_used_at
,        first_used_at
,        user_id
,        feature_name
,        is_active
,        version
    from source
)
select * from renamed
