with a as (
    select * from {{ ref('stg_users_04') }}
),

b as (
    select * from {{ ref('int_model_050') }}
)

select
    a.*,
    b.*
from a
inner join b on a.invoice_id = b.invoice_id
