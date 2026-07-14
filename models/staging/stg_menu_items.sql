select
    item_id,
    item_name,
    price as current_price
from {{ ref ("raw_menu_items") }}
