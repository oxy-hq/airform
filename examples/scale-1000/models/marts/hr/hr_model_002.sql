with a as (
    select * from {{ ref('stg_products_02') }}
),

b as (
    select * from {{ ref('int_model_137') }}
)

select
    a.*,
    b.*
from a
inner join b on a.account_id = b.account_id
