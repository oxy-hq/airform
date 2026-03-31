with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        net_amount
,        currency
,        fee
,        method
,        status
,        invoice_id
    from source
)
select * from renamed
