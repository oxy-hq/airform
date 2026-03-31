with base as (select * from {{ ref('stg_shipments_056') }}),
ranked as (select *, row_number() over (partition by department_id order by employee_id) as rn from base)
select * from ranked where rn = 1
