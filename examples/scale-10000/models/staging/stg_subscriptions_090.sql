with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        status
,        amount
,        currency
,        end_date
    from source
)
select * from renamed
