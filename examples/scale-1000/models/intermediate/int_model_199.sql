with source as (
    select * from {{ ref('stg_compliance_records_09') }}
),

final as (
    select
        *,
        row_number() over (partition by order_id order by shipment_id) as row_num
    from source
)

select * from final
