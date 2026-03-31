with base as (select * from {{ ref('stg_warehouses_014') }}),
ranked as (select *, row_number() over (partition by campaign_name order by campaign_id) as rn from base)
select * from ranked where rn = 1
