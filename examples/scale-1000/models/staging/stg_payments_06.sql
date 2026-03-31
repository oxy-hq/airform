with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        reference_id
,        method
,        status
,        amount
,        net_amount
,        currency
    from source
)

select * from renamed
