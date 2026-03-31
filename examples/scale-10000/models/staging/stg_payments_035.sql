with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        fee
,        status
,        net_amount
,        invoice_id
,        processed_at
,        method
    from source
)
select * from renamed
