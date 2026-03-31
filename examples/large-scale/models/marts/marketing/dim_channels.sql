with sessions as (
    select * from {{ ref('stg_sessions') }}
),

final as (
    select distinct
        referrer,
        case referrer
            when 'direct' then 'Direct'
            when 'google' then 'Organic Search'
            when 'email' then 'Email'
            when 'paid_ad' then 'Paid'
            when 'referral' then 'Referral'
            else 'Other'
        end as channel_name,
        case referrer
            when 'direct' then 'owned'
            when 'google' then 'earned'
            when 'email' then 'owned'
            when 'paid_ad' then 'paid'
            when 'referral' then 'earned'
            else 'other'
        end as channel_category
    from sessions
)

select * from final
