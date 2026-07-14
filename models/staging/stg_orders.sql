select 
    order_id,
    customer_name,
    item_id,
    quantity,
    order_timestamp
from {{ ref('raw_orders') }}