with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        version
,        usage_count
,        user_id
,        first_used_at
    from source
)
select * from renamed
