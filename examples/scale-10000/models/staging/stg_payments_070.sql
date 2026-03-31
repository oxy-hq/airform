with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        invoice_id
,        currency
,        status
,        fee
    from source
)
select * from renamed
