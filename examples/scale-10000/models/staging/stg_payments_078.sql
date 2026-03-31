with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        reference_id
,        fee
,        method
,        amount
,        processed_at
,        status
    from source
)
select * from renamed
