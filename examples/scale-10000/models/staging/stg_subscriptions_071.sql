with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        currency
,        interval_months
,        status
,        end_date
,        amount
,        start_date
    from source
)
select * from renamed
