with a as (select * from {{ ref('stg_support_tickets_012') }}),
b as (select * from {{ ref('int_model_0900') }})
select a.* from a inner join b on a.order_id = b.order_id
