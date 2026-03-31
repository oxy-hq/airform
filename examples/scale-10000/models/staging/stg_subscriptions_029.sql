with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        auto_renew
,        account_id
,        end_date
,        amount
    from source
)
select * from renamed
