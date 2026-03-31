with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        invoice_id
,        net_amount
,        reference_id
,        amount
,        status
    from source
)
select * from renamed
