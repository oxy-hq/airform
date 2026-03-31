with a as (select * from {{ ref('stg_orders_020') }}),
b as (select * from {{ ref('int_model_1692') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
