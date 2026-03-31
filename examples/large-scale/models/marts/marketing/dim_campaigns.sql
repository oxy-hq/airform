with users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select distinct
        signup_source,
        case signup_source
            when 'organic' then 'Organic Search'
            when 'referral' then 'Referral Program'
            when 'paid_ad' then 'Paid Advertising'
            else 'Other'
        end as campaign_name,
        case signup_source
            when 'organic' then 'inbound'
            when 'referral' then 'viral'
            when 'paid_ad' then 'paid'
            else 'other'
        end as campaign_type,
        case signup_source
            when 'paid_ad' then 50
            when 'referral' then 25
            else 0
        end as estimated_cac
    from users
)

select * from final
