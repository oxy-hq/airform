with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        currency
,        amount
,        fee
    from source
)
select * from renamed
