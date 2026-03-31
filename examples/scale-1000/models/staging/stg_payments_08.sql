with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        status
,        invoice_id
,        method
,        reference_id
,        processed_at
,        net_amount
,        currency
    from source
)

select * from renamed
