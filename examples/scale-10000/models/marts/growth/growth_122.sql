with a as (select * from {{ ref('stg_shipments_022') }}),
b as (select * from {{ ref('int_model_0462') }})
select a.* from a inner join b on a.account_id = b.account_id
