with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        reference_id
,        net_amount
,        invoice_id
,        method
,        status
,        currency
    from source
)

select * from renamed
