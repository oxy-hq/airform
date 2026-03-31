with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        end_date
,        start_date
,        interval_months
,        amount
,        plan_id
,        currency
,        account_id
    from source
)
select * from renamed
