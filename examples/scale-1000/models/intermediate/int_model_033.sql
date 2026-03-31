with a as (
    select * from {{ ref('stg_invoices_03') }}
),

b as (
    select * from {{ ref('stg_invoices_10') }}
),

final as (
    select
        a.order_item_id,
        a.order_id,
        a.product_id,
        b.compliance_record_id,
        b.account_id,
        b.record_type
    from a
    left join b on a.order_item_id = b.compliance_record_id
)

select * from final
