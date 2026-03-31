with source as (
    select * from {{ ref('stg_shipments_10') }}
),

final as (
    select
        user_id,
        count(*) as record_count,
        sum(cast(feature_usage_id as int)) as total_feature_usage_id
    from source
    group by user_id
)

select * from final
