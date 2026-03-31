with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        reference_id
,        status
,        currency
,        net_amount
,        invoice_id
,        method
    from source
)
select * from renamed
