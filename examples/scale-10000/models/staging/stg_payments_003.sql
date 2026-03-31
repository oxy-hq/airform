with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        status
,        processed_at
,        currency
,        net_amount
,        invoice_id
    from source
)
select * from renamed
