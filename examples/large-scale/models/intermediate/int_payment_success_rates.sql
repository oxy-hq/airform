with payments as (
    select * from {{ ref('stg_payments') }}
),

invoices as (
    select * from {{ ref('stg_invoices') }}
),

payment_stats as (
    select
        invoices.account_id,
        count(*) as total_attempts,
        sum(case when payments.status = 'succeeded' then 1 else 0 end) as successful_attempts,
        sum(case when payments.status = 'failed' then 1 else 0 end) as failed_attempts,
        sum(case when payments.status = 'refunded' then 1 else 0 end) as refunded_attempts
    from payments
    left join invoices on payments.invoice_id = invoices.invoice_id
    group by invoices.account_id
)

select
    account_id,
    total_attempts,
    successful_attempts,
    failed_attempts,
    refunded_attempts,
    case
        when total_attempts > 0
        then cast(successful_attempts as float) / cast(total_attempts as float)
        else 0
    end as success_rate
from payment_stats
