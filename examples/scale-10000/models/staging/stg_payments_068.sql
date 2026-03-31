with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        amount
,        fee
,        net_amount
,        status
,        processed_at
    from source
)
select * from renamed
