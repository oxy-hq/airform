with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        processed_at
,        invoice_id
,        reference_id
,        fee
,        amount
    from source
)

select * from renamed
