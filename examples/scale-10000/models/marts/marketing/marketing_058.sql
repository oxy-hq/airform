with base as (select * from {{ ref('stg_sessions_058') }}),
ranked as (select *, row_number() over (partition by warehouse_name order by warehouse_id) as rn from base)
select * from ranked where rn = 1
