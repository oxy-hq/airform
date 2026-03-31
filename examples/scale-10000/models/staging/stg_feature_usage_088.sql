with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        version
,        feature_name
,        usage_count
,        user_id
    from source
)
select * from renamed
