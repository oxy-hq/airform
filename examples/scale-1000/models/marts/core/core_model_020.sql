with a as (
    select * from {{ ref('stg_accounts_10') }}
),

b as (
    select * from {{ ref('int_model_023') }}
)

select
    a.*,
    b.*
from a
inner join b on a.compliance_record_id = b.compliance_record_id
