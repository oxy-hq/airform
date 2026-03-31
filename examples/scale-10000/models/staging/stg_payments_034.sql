with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        status
,        invoice_id
,        reference_id
,        amount
    from source
)
select * from renamed
