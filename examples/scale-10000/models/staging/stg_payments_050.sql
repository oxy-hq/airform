with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        processed_at
,        amount
,        currency
,        reference_id
,        status
,        net_amount
    from source
)
select * from renamed
