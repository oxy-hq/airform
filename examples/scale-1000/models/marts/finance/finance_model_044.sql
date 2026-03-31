with a as (
    select * from {{ ref('stg_products_04') }}
),

b as (
    select * from {{ ref('int_model_117') }}
)

select
    a.*,
    b.*
from a
inner join b on a.invoice_id = b.invoice_id
