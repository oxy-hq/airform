with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        account_id
,        plan_id
,        currency
,        amount
,        interval_months
    from source
)
select * from renamed
