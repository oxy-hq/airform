with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        category
,        is_active
,        feature_name
,        first_used_at
,        version
,        usage_count
    from source
)
select * from renamed
