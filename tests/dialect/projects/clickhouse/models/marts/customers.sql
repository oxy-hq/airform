{{ config(materialized='table') }}

select
    u.id as customer_id,
    u.first_name,
    u.last_name,
    u.email,
    u.country,
    ifNull(sum(o.order_amount), 0) as lifetime_value,
    count(o.order_id) as order_count
from {{ ref('stg_users') }} u
left join {{ ref('stg_orders') }} o on u.id = o.user_id
group by u.id, u.first_name, u.last_name, u.email, u.country
