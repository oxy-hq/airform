with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        auto_renew
,        plan_id
,        currency
,        amount
,        account_id
    from source
)
select * from renamed
