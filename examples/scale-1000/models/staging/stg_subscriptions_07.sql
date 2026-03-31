with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        amount
,        plan_id
,        status
,        account_id
,        auto_renew
,        end_date
    from source
)

select * from renamed
