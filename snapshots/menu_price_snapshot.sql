{% snapshot menu_price_snapshot %}

{{
	config(
	    target_schema='snapshots',
	    unique_key='item_id',
    	    strategy='check',
	    check_cols=['current_price']
	)
}}

select 
    item_id,
    item_name,
    current_price
from {{ ref('stg_menu_items') }}

{% endsnapshot %}
