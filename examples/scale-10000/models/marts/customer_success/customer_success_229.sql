select support_ticket_id, user_id, account_id, subject, priority
from {{ ref('stg_order_items_029') }}
