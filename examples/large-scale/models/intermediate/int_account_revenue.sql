with invoices as (
    select * from {{ ref('stg_invoices') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

successful_payments as (
    select
        invoice_id,
        sum(amount) as paid_amount
    from payments
    where status = 'succeeded'
    group by invoice_id
),

final as (
    select
        invoices.account_id,
        count(distinct invoices.invoice_id) as total_invoices,
        sum(invoices.amount) as total_invoiced,
        sum(coalesce(successful_payments.paid_amount, 0)) as total_collected,
        sum(case when invoices.status = 'paid' then invoices.amount else 0 end) as paid_revenue,
        sum(case when invoices.status = 'open' then invoices.amount else 0 end) as outstanding_revenue
    from invoices
    left join successful_payments on invoices.invoice_id = successful_payments.invoice_id
    group by invoices.account_id
)

select * from final
