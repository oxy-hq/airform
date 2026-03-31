with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        status
,        processed_at
,        amount
,        currency
,        fee
    from source
)
select * from renamed
