with users as (
    select * from {{ ref('stg_users') }}
),

account_revenue as (
    select * from {{ ref('int_account_revenue') }}
),

final as (
    select
        users.signup_source,
        users.account_id,
        users.user_id,
        users.created_at as signup_at,
        coalesce(account_revenue.total_collected, 0) as attributed_revenue,
        users.status
    from users
    left join account_revenue on users.account_id = account_revenue.account_id
)

select * from final
