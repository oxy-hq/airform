with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        fee
,        reference_id
,        method
,        status
,        net_amount
,        invoice_id
    from source
)
select * from renamed
