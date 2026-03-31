with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        currency
,        amount
,        end_date
,        auto_renew
    from source
)

select * from renamed
