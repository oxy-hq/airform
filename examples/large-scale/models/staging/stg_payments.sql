with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id,
        invoice_id,
        amount,
        method as payment_method,
        status,
        processed_at
    from source
)

select * from renamed
