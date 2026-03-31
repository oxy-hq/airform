with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        auto_renew
,        end_date
,        plan_id
,        amount
,        interval_months
,        currency
    from source
)
select * from renamed
