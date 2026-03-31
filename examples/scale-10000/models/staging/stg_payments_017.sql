with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        invoice_id
,        fee
    from source
)
select * from renamed
