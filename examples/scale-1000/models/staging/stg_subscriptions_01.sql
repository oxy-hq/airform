with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        auto_renew
,        amount
,        account_id
,        status
,        currency
,        interval_months
    from source
)

select * from renamed
