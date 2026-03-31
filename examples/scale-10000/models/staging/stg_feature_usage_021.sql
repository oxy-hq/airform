with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        last_used_at
,        is_active
,        first_used_at
,        feature_name
    from source
)
select * from renamed
