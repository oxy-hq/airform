with a as (
    select * from {{ ref('stg_departments_05') }}
),

b as (
    select * from {{ ref('stg_warehouses_02') }}
),

final as (
    select
        a.payment_id,
        a.invoice_id,
        a.amount,
        b.order_id,
        b.account_id,
        b.user_id
    from a
    left join b on a.payment_id = b.order_id
)

select * from final
