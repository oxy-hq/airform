with a as (select * from {{ ref('stg_channels_082') }}),
b as (select * from {{ ref('int_model_1868') }})
select a.* from a inner join b on a.account_id = b.account_id
