with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        net_amount
,        amount
,        method
,        currency
,        invoice_id
,        fee
,        processed_at
    from source
)
select * from renamed
