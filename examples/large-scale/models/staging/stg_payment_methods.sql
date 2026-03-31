with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

final as (
    select
        id as payment_id,
        invoice_id,
        amount,
        method as payment_method,
        case method
            when 'credit_card' then 'card'
            when 'bank_transfer' then 'bank'
            else 'other'
        end as payment_category,
        status,
        processed_at
    from source
)

select * from final
