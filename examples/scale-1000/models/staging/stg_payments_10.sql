with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        processed_at
,        invoice_id
,        amount
,        fee
,        net_amount
    from source
)

select * from renamed
