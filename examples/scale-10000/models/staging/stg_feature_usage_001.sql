with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        feature_name
,        version
,        is_active
    from source
)
select * from renamed
