with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        processed_at
,        method
,        invoice_id
,        net_amount
,        fee
,        status
    from source
)
select * from renamed
