with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        interval_months
,        auto_renew
,        start_date
    from source
)
select * from renamed
