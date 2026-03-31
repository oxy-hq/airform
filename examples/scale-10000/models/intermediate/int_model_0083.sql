select *, row_number() over (partition by account_id order by subscription_id) as rn
from {{ ref('stg_users_083') }}
