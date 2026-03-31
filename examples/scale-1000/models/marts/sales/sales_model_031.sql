select
    product_id, product_name, category, price, cost
from {{ ref('stg_compliance_records_01') }}
