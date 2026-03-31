with payments as (
    select * from {{ ref('stg_payments') }}
),

methods as (
    select * from {{ ref('stg_payment_methods') }}
),

invoices as (
    select * from {{ ref('stg_invoices') }}
),

final as (
    select
        payments.payment_id,
        payments.invoice_id,
        invoices.account_id,
        payments.amount,
        payments.payment_method,
        methods.payment_category,
        payments.status,
        payments.processed_at,
        case
            when payments.status = 'succeeded' then payments.amount
            else 0
        end as net_amount
    from payments
    left join methods on payments.payment_id = methods.payment_id
    left join invoices on payments.invoice_id = invoices.invoice_id
)

select * from final
