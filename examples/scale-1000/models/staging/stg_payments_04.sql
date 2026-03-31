with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        status
,        processed_at
,        fee
,        currency
    from source
)

select * from renamed
