with a as (select * from {{ ref('stg_sessions_024') }}),
b as (select * from {{ ref('int_model_0913') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
