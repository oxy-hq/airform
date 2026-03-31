select user_id, account_id, email, first_name, last_name
from {{ ref('stg_support_tickets_021') }}
