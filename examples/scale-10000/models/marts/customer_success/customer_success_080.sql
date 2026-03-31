with a as (select * from {{ ref('stg_products_080') }}),
b as (select * from {{ ref('int_model_1417') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
