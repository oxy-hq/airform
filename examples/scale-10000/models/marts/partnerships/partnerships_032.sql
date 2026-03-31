with a as (select * from {{ ref('stg_support_tickets_032') }}),
b as (select * from {{ ref('int_model_1366') }})
select a.* from a inner join b on a.order_id = b.order_id
