with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),

renamed as (
    select
        id as feature_usage_id
,        platform
,        version
,        feature_name
    from source
)

select * from renamed
