with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        usage_count
,        user_id
,        last_used_at
,        category
,        version
    from source
)
select * from renamed
