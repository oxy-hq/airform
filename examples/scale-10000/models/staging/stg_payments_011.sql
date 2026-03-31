with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        net_amount
,        amount
,        processed_at
,        fee
,        currency
    from source
)
select * from renamed
