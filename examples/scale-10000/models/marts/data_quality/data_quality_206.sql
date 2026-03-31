with a as (select * from {{ ref('stg_accounts_006') }}),
b as (select * from {{ ref('int_model_0554') }})
select a.* from a inner join b on a.event_id = b.event_id
