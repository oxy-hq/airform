with invoice_payments as (
    select * from {{ ref('int_invoice_payments') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

plans as (
    select * from {{ ref('stg_account_plans') }}
),

final as (
    select
        invoice_payments.invoice_id,
        invoice_payments.account_id,
        accounts.account_name,
        plans.plan_name,
        invoice_payments.invoice_amount,
        invoice_payments.total_paid,
        invoice_payments.invoice_status,
        invoice_payments.issued_at,
        invoice_payments.paid_at,
        case
            when invoice_payments.invoice_status = 'paid' then 'recognized'
            when invoice_payments.invoice_status = 'open' then 'pending'
            else 'void'
        end as revenue_status
    from invoice_payments
    left join accounts on invoice_payments.account_id = accounts.account_id
    left join plans on invoice_payments.account_id = plans.account_id
)

select * from final
