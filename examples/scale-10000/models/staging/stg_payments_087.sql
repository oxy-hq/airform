with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        status
,        reference_id
,        currency
,        amount
,        method
,        fee
    from source
)
select * from renamed
