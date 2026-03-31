with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        category
,        is_active
,        first_used_at
,        version
,        user_id
,        last_used_at
,        usage_count
    from source
)
select * from renamed
