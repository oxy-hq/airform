with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        currency
,        processed_at
,        net_amount
    from source
)
select * from renamed
