with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        reference_id
,        method
,        status
,        currency
,        fee
,        net_amount
,        processed_at
    from source
)
select * from renamed
