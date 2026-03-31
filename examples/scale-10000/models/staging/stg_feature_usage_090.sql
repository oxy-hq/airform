with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        usage_count
,        user_id
,        version
,        first_used_at
,        is_active
    from source
)
select * from renamed
