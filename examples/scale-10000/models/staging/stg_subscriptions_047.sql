with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        auto_renew
,        amount
,        account_id
,        status
    from source
)
select * from renamed
