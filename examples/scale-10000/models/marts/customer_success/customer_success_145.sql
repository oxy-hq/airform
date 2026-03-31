select payment_id, invoice_id, amount, method, status
from {{ ref('stg_orders_045') }}
