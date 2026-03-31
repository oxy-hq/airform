with invoices as (
    select * from {{ ref('stg_invoices') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

payment_agg as (
    select
        invoice_id,
        sum(case when status = 'succeeded' then amount else 0 end) as total_paid,
        count(*) as payment_attempts,
        sum(case when status = 'succeeded' then 1 else 0 end) as successful_payments
    from payments
    group by invoice_id
),

final as (
    select
        invoices.invoice_id,
        invoices.account_id,
        invoices.subscription_id,
        invoices.amount as invoice_amount,
        invoices.status as invoice_status,
        invoices.issued_at,
        invoices.paid_at,
        coalesce(payment_agg.total_paid, 0) as total_paid,
        coalesce(payment_agg.payment_attempts, 0) as payment_attempts,
        coalesce(payment_agg.successful_payments, 0) as successful_payments
    from invoices
    left join payment_agg on invoices.invoice_id = payment_agg.invoice_id
)

select * from final
