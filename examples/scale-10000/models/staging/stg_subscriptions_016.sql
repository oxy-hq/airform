with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        status
,        start_date
,        plan_id
,        auto_renew
,        end_date
,        amount
    from source
)
select * from renamed
