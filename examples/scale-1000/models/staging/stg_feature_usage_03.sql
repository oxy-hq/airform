with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        first_used_at
,        version
,        user_id
,        feature_name
,        usage_count
,        platform
    from source
)

select * from renamed
