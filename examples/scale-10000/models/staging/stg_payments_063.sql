with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        fee
,        status
,        net_amount
,        processed_at
,        currency
    from source
)
select * from renamed
