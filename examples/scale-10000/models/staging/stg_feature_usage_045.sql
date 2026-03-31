with source as (
    select * from {{ source('raw', 'raw_feature_usage') }}
),
renamed as (
    select
        id as feature_usage_id
,        last_used_at
,        usage_count
,        version
,        first_used_at
    from source
)
select * from renamed
