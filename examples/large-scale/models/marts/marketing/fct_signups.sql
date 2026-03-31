with users as (
    select * from {{ ref('stg_users') }}
),

cohorts as (
    select * from {{ ref('int_user_signup_cohorts') }}
),

final as (
    select
        users.user_id,
        users.email,
        users.first_name,
        users.last_name,
        users.signup_source,
        users.country,
        users.created_at as signup_at,
        cast(users.created_at as date) as signup_date,
        cohorts.signup_quarter,
        users.account_id,
        users.status
    from users
    left join cohorts on users.user_id = cohorts.user_id
)

select * from final
