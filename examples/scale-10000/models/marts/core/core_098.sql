with a as (select * from {{ ref('stg_users_098') }}),
b as (select * from {{ ref('int_model_0107') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
