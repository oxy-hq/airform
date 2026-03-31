with users as (
    select * from {{ ref('stg_users') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        users.user_id,
        users.email,
        users.first_name,
        users.last_name,
        users.status as user_status,
        users.country,
        users.signup_source,
        users.created_at as user_created_at,
        accounts.account_id,
        accounts.account_name,
        accounts.industry,
        accounts.company_size,
        accounts.status as account_status
    from users
    left join accounts on users.account_id = accounts.account_id
)

select * from final
