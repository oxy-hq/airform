with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        is_active
,        feature_name
,        category
,        version
,        first_used_at
,        usage_count
    from source
)
select * from renamed
