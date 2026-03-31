with a as (
    select * from {{ ref('stg_users_02') }}
),

b as (
    select * from {{ ref('int_model_003') }}
)

select
    a.*,
    b.*
from a
inner join b on a.account_id = b.account_id
