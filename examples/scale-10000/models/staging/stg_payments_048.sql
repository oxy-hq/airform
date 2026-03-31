with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        processed_at
,        reference_id
,        amount
,        status
,        net_amount
    from source
)
select * from renamed
