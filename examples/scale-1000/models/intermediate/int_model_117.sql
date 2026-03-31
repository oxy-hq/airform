with a as (
    select * from {{ ref('stg_orders_07') }}
),

b as (
    select * from {{ ref('stg_order_items_04') }}
),

final as (
    select
        a.department_id,
        a.department_name,
        a.cost_center,
        b.invoice_id,
        b.account_id,
        b.invoice_date
    from a
    left join b on a.department_id = b.invoice_id
)

select * from final
