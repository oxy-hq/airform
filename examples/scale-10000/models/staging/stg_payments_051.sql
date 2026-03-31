with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        status
,        net_amount
,        fee
,        reference_id
,        invoice_id
,        currency
    from source
)
select * from renamed
