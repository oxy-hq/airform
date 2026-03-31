with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        currency
,        method
,        processed_at
,        fee
,        reference_id
,        net_amount
    from source
)
select * from renamed
