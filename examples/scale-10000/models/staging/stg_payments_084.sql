with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        reference_id
,        invoice_id
,        currency
,        method
,        amount
,        fee
,        net_amount
    from source
)
select * from renamed
