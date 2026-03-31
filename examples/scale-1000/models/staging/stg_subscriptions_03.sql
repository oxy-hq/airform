with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        interval_months
,        plan_id
,        amount
,        auto_renew
,        status
,        end_date
,        account_id
    from source
)

select * from renamed
