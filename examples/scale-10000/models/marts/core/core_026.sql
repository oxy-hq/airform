with a as (select * from {{ ref('stg_users_026') }}),
b as (select * from {{ ref('int_model_0027') }})
select a.* from a inner join b on a.event_id = b.event_id
