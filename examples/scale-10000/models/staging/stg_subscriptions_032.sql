with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        end_date
,        account_id
,        currency
,        start_date
,        interval_months
,        auto_renew
,        amount
    from source
)
select * from renamed
