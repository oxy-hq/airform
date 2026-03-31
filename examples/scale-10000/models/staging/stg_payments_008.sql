with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        invoice_id
,        status
,        reference_id
,        net_amount
,        processed_at
    from source
)
select * from renamed
