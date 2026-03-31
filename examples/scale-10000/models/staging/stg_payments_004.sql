with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        net_amount
,        currency
,        method
    from source
)
select * from renamed
