with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        amount
,        net_amount
,        fee
,        method
,        invoice_id
    from source
)

select * from renamed
