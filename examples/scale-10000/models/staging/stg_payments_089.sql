with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        amount
,        invoice_id
,        fee
,        status
    from source
)
select * from renamed
