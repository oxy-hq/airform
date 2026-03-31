with a as (select * from {{ ref('stg_compliance_records_012') }}),
b as (select * from {{ ref('int_model_0560') }})
select a.* from a inner join b on a.order_id = b.order_id
