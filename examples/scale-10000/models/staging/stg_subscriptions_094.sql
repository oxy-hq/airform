with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        start_date
,        currency
,        status
,        plan_id
,        amount
    from source
)
select * from renamed
