with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        net_amount
,        invoice_id
,        status
,        reference_id
,        method
,        currency
    from source
)
select * from renamed
