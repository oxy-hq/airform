with invoices as (
    select * from {{ ref('stg_invoices') }}
),

invoice_payments as (
    select * from {{ ref('int_invoice_payments') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        invoices.invoice_id,
        invoices.account_id,
        accounts.account_name,
        invoices.subscription_id,
        invoices.amount,
        invoices.currency,
        invoices.status,
        invoices.issued_at,
        invoices.due_at,
        invoices.paid_at,
        invoice_payments.payment_attempts,
        invoice_payments.successful_payments,
        case
            when invoices.paid_at is not null and invoices.paid_at <= invoices.due_at then 'on_time'
            when invoices.paid_at is not null and invoices.paid_at > invoices.due_at then 'late'
            when invoices.status = 'open' then 'outstanding'
            else 'void'
        end as payment_timeliness
    from invoices
    left join invoice_payments on invoices.invoice_id = invoice_payments.invoice_id
    left join accounts on invoices.account_id = accounts.account_id
)

select * from final
