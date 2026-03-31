with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        amount
,        currency
,        start_date
,        end_date
,        auto_renew
,        status
,        account_id
    from source
)
select * from renamed
