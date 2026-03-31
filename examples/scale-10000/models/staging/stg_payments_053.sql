with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        method
,        status
,        processed_at
,        currency
,        invoice_id
,        net_amount
    from source
)
select * from renamed
