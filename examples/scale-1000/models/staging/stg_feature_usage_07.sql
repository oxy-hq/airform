with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        is_active
,        category
,        usage_count
,        platform
,        version
,        user_id
    from source
)

select * from renamed
