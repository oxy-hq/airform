with base as (select * from {{ ref('stg_departments_052') }}),
ranked as (select *, row_number() over (partition by account_id order by order_id) as rn from base)
select * from ranked where rn = 1
