with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

final as (
    select
        id as subscription_id,
        account_id,
        monthly_amount,
        billing_interval,
        case billing_interval
            when 'annual' then monthly_amount * 12
            else monthly_amount
        end as normalized_annual_amount,
        status
    from source
)

select * from final
