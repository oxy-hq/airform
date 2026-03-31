with a as (select * from {{ ref('stg_compliance_records_042') }}),
b as (select * from {{ ref('int_model_0595') }})
select a.* from a inner join b on a.account_id = b.account_id
