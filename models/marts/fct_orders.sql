{{
    config(
       materialized='incremental',
       unique_key='order_id'
    )
}}

select 	
    order_id,
    customer_name,
    item_id,
    quantity,
    order_timestamp
from {{ ref('stg_orders') }}

{% if is_incremental() %}
where order_timestamp > (select max(order_timestamp) from {{ this }})
{% endif %}

