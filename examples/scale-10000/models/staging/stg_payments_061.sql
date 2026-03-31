with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        fee
,        currency
,        invoice_id
,        amount
,        status
    from source
)
select * from renamed
