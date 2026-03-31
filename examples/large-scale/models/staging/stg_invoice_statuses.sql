with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

final as (
    select
        id as invoice_id,
        status,
        case status
            when 'paid' then 'closed'
            when 'void' then 'closed'
            when 'open' then 'open'
            else 'unknown'
        end as status_category,
        case
            when status = 'paid' then 1
            else 0
        end as is_paid,
        amount,
        issued_at
    from source
)

select * from final
