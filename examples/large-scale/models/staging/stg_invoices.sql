with source as (
    select * from {{ source('raw', 'raw_invoices') }}
),

renamed as (
    select
        id as invoice_id,
        account_id,
        subscription_id,
        amount,
        currency,
        status,
        issued_at,
        due_at,
        paid_at
    from source
)

select * from renamed
