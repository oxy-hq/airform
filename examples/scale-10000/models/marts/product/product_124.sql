with base as (select * from {{ ref('stg_products_024') }}),
ranked as (select *, row_number() over (partition by account_id order by invoice_id) as rn from base)
select * from ranked where rn = 1
