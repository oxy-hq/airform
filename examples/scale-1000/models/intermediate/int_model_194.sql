with source as (
    select * from {{ ref('stg_compliance_records_04') }}
),

final as (
    select
        campaign_name,
        count(*) as record_count,
        sum(cast(campaign_id as int)) as total_campaign_id
    from source
    group by campaign_name
)

select * from final
