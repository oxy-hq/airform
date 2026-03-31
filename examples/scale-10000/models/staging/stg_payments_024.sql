with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        processed_at
,        currency
,        amount
,        net_amount
,        method
,        status
    from source
)
select * from renamed
