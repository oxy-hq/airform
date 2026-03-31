with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

final as (
    select
        id as invoice_id,
        account_id,
        subscription_id,
        amount,
        currency,
        status,
        issued_at,
        due_at,
        paid_at,
        case
            when status = 'paid' then amount
            else 0
        end as collected_amount
    from source
)

select * from final
