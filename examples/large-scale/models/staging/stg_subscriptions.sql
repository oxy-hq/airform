with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id,
        account_id,
        plan_id,
        started_at,
        ended_at,
        status,
        monthly_amount,
        billing_interval
    from source
)

select * from renamed
