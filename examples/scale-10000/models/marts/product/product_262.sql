with base as (select * from {{ ref('stg_orders_062') }}),
ranked as (select *, row_number() over (partition by account_name order by account_id) as rn from base)
select * from ranked where rn = 1
