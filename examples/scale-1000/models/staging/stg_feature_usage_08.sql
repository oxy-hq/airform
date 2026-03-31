with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        usage_count
,        is_active
,        last_used_at
,        user_id
,        category
,        version
    from source
)

select * from renamed
