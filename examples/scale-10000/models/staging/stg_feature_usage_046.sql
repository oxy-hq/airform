with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        last_used_at
,        user_id
,        is_active
,        category
,        version
    from source
)
select * from renamed
