with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        account_id
,        status
,        amount
,        start_date
,        currency
,        auto_renew
    from source
)
select * from renamed
