with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        interval_months
,        account_id
,        auto_renew
,        start_date
,        end_date
    from source
)
select * from renamed
