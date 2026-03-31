with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        amount
,        processed_at
,        net_amount
,        status
,        method
    from source
)
select * from renamed
