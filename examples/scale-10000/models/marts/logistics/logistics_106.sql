with base as (select * from {{ ref('stg_subscriptions_006') }}),
ranked as (select *, row_number() over (partition by user_id order by event_id) as rn from base)
select * from ranked where rn = 1
