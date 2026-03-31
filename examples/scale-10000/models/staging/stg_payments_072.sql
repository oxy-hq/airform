with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        net_amount
,        invoice_id
,        amount
,        currency
,        processed_at
,        method
    from source
)
select * from renamed
