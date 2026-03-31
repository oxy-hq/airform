with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        category
,        version
,        is_active
,        last_used_at
,        feature_name
,        user_id
,        usage_count
    from source
)
select * from renamed
