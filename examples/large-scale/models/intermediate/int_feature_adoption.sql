with feature_usage as (
    select * from {{ ref('stg_feature_usage') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

total_users as (
    select count(distinct user_id) as user_count from users
),

feature_stats as (
    select
        feature_name,
        count(distinct user_id) as users_using,
        sum(usage_count) as total_usage,
        avg(duration_seconds) as avg_duration
    from feature_usage
    group by feature_name
)

select
    feature_stats.feature_name,
    feature_stats.users_using,
    feature_stats.total_usage,
    feature_stats.avg_duration,
    total_users.user_count as total_users,
    case
        when total_users.user_count > 0
        then cast(feature_stats.users_using as float) / cast(total_users.user_count as float)
        else 0
    end as adoption_rate
from feature_stats
cross join total_users
