with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        interval_months
,        account_id
,        end_date
,        plan_id
,        status
,        currency
,        amount
    from source
)

select * from renamed
