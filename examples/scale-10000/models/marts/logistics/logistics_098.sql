with a as (select * from {{ ref('stg_accounts_098') }}),
b as (select * from {{ ref('int_model_0436') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
