with a as (select * from {{ ref('stg_compliance_records_092') }}),
b as (select * from {{ ref('int_model_0430') }})
select a.* from a inner join b on a.order_id = b.order_id
