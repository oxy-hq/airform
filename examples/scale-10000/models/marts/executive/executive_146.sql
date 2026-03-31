with a as (select * from {{ ref('stg_invoices_046') }}),
b as (select * from {{ ref('int_model_0825') }})
select a.* from a inner join b on a.event_id = b.event_id
