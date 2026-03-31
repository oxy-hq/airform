with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        plan_id
,        amount
,        account_id
,        interval_months
,        start_date
,        status
    from source
)
select * from renamed
