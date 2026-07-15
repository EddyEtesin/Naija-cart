# Naija Cart

A small data project that tracks food orders from a fictional Nigerian street-food
vendor (suya, amala, moi moi, etc.) and calculates what each order actually cost —
correctly, even when prices change over time.

---

## In a more simplified term

Imagine a suya spot. Suya used to cost ₦500, but the price recently went up to ₦700.

Now imagine someone asks: **"How much money did we make from suya sales last week?"**

If you just multiply *last week's orders* by *today's price* (₦700), you'd get the
wrong answer — because most of those orders happened when suya was still ₦500.
You'd be overcharging the past for something that hadn't happened yet.

This project solves that problem. It:
1. Keeps a record of every order (who bought what, how many, and when)
2. Keeps a **history** of every price change, not just the current price
3. Matches every order to the price that was *actually true at the time that
   order happened* — not today's price

The result is a report where every order shows the correct amount it actually
cost, no matter how many times prices have changed since.

This is the same problem real businesses deal with constantly — accounting,
inventory, sales reporting — anywhere the "current" version of something isn't
good enough, and you need to know what was true *back then*.

---

## Technical overview

Built with **dbt** (data transformation tool) and **DuckDB** (local database)
as a learning project, following a standard layered pipeline:

```
raw_orders.csv  ──────────────► stg_orders ──────────► fct_orders (incremental)
                                                                    │
raw_menu_items.csv ──► stg_menu_items ──► menu_price_snapshot ──────┤
                                          (SCD Type 2 history)      │
                                                                    ▼
                                                          fct_orders_priced
                                                          (point-in-time
                                                           correct pricing)
```

**Key concepts demonstrated:**

- **Seeds** — raw CSVs (`raw_orders`, `raw_menu_items`) loaded as source tables
- **Staging models** — light cleanup/renaming layer on top of raw data
- **Snapshots (SCD Type 2)** — `menu_price_snapshot` tracks every price change
  over time using dbt's `check` strategy, auto-generating `dbt_valid_from` /
  `dbt_valid_to` columns to mark when each price was valid
- **Incremental models** — `fct_orders` only processes new rows on each run
  (via `is_incremental()` + `{{ this }}`) instead of rebuilding from scratch
- **Point-in-time join** — `fct_orders_priced` joins each order to the
  snapshot using a time-range condition:
  ```sql
  on o.item_id = m.item_id
  and o.order_timestamp >= m.dbt_valid_from
  and (o.order_timestamp < m.dbt_valid_to or m.dbt_valid_to is null)
  ```
  This ensures each order is priced using whatever was true *at that moment*,
  not the current price.

**Verified with real data:** a price change was simulated (Suya Stick ₦500 → ₦700),
and orders placed before/after the change were confirmed to show the correct
historical price and order total.

**Stack:** dbt-core, dbt-duckdb, DuckDB (local file-based database)

**To run locally:**
```
dbt seed
dbt run
dbt snapshot
dbt run --select fct_orders_priced
```
