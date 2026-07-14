select
    o.order_id,
    o.customer_name,
    o.item_id,
    m.item_name,
    o.quantity,
    order_timestamp,
    m.current_price as price_at_order_time,
    o.quantity * m.current_price as order_total
from {{ ref('fct_orders') }} o

left join {{ ref('menu_price_snapshot') }} m 
    on o.item_id = m.item_id
    and o.order_timestamp >= m.dbt_valid_from
    and (o.order_timestamp < m.dbt_valid_to or m.dbt_valid_to is null)