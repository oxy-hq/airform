with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        invoice_id
,        amount
,        status
,        fee
,        net_amount
    from source
)
select * from renamed
