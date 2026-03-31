with base as (select * from {{ ref('stg_shipments_090') }}),
ranked as (select *, row_number() over (partition by user_id order by feature_usage_id) as rn from base)
select * from ranked where rn = 1
