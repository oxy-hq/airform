with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        currency
,        processed_at
,        fee
,        status
,        reference_id
    from source
)
select * from renamed
