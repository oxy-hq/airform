with  __dbt__cte__int_recharge__customer_details as (
with customers as (
    select *
    from "recharge"."main_recharge_source"."stg_recharge__customer"

), billing as (
    select *
    from "recharge"."main_recharge"."recharge__billing_history"

-- Agg'd on customer_id and source_relation
), order_aggs as (
    select
        source_relation,
        customer_id,
        count(order_id) as total_orders,
        round(cast(sum(order_total_price) as numeric(28,6)), 2) as total_amount_ordered,
        round(cast(avg(order_total_price) as numeric(28,6)), 2) as avg_order_amount,
        round(cast(sum(order_item_quantity) as numeric(28,6)), 2) as total_quantity_ordered,
        round(cast(avg(order_item_quantity) as numeric(28,6)), 2) as avg_item_quantity_per_order,
        round(cast(sum(order_line_item_total) as numeric(28,6)), 2) as total_order_line_item_total,
        round(cast(avg(order_line_item_total) as numeric(28,6)), 2) as avg_order_line_item_total
    from billing
    where lower(order_status) not in ('error', 'cancelled', 'queued') --possible values: success, error, queued, skipped, refunded or partially_refunded
    group by 1, 2

), charge_aggs as (
    select
        source_relation,
        customer_id,
        count(distinct charge_id) as charges_count,
        round(cast(sum(charge_total_price) as numeric(28,6)), 2) as total_amount_charged,
        round(cast(avg(charge_total_price) as numeric(28,6)), 2) as avg_amount_charged,
        round(cast(sum(charge_total_tax) as numeric(28,6)), 2) as total_amount_taxed,
        round(cast(sum(charge_total_discounts) as numeric(28,6)), 2) as total_amount_discounted,
        round(cast(sum(charge_total_refunds) as numeric(28,6)), 2) as total_refunds,
        count(case when lower(billing.charge_type) = 'checkout' then 1 else null end) as total_one_time_purchases
    from billing
    where lower(charge_status) not in ('error', 'skipped', 'queued')
    group by 1, 2

), subscriptions as (
    select
        source_relation,
        customer_id,
        count(subscription_id) as calculated_subscriptions_active_count -- this value may differ from the recharge-provided subscriptions_active_count. See DECISIONLOG.
    from "recharge"."main_recharge_source"."stg_recharge__subscription"
    where lower(subscription_status) = 'active'
    group by 1, 2

), joined as (
    select
        customers.*,
        order_aggs.total_orders,
        order_aggs.total_amount_ordered,
        order_aggs.avg_order_amount,
        order_aggs.total_order_line_item_total,
        order_aggs.avg_order_line_item_total,
        order_aggs.avg_item_quantity_per_order, --units_per_transaction
        charge_aggs.total_amount_charged,
        charge_aggs.avg_amount_charged,
        charge_aggs.charges_count,
        charge_aggs.total_amount_taxed,
        charge_aggs.total_amount_discounted,
        charge_aggs.total_refunds,
        charge_aggs.total_one_time_purchases,
        round(cast(charge_aggs.avg_amount_charged - charge_aggs.total_refunds as numeric(28,6)), 2)
            as total_net_spend,
        coalesce(subscriptions.calculated_subscriptions_active_count, 0) as calculated_subscriptions_active_count
    from customers
    left join charge_aggs
        on charge_aggs.customer_id = customers.customer_id
        and charge_aggs.source_relation = customers.source_relation
    left join order_aggs
        on order_aggs.customer_id = customers.customer_id
        and order_aggs.source_relation = customers.source_relation
    left join subscriptions
        on subscriptions.customer_id = customers.customer_id
        and subscriptions.source_relation = customers.source_relation

)

select *
from joined
), customers as (
    select *
    from __dbt__cte__int_recharge__customer_details

), enriched as (
    select
        customers.*,
        case when subscriptions_active_count > 0
            then true else false end as is_currently_subscribed,
        case when date_diff('day', first_charge_processed_at::timestamp, 
    current_timestamp::timestamp
::timestamp ) <= 30
            then true else false end as is_new_customer,
        round(cast(date_diff('day', first_charge_processed_at::timestamp, 
    current_timestamp::timestamp
::timestamp ) / 30 as numeric(28,6)), 2)
            as active_months
    from customers

), aggs as (
    select
        enriched.*,
        
        
            round(cast(
    ( total_orders ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as orders_monthly_average -- calculates average over no. active mos
            ,
            round(cast(
    ( total_amount_ordered ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as amount_ordered_monthly_average -- calculates average over no. active mos
            ,
            round(cast(
    ( total_one_time_purchases ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as one_time_purchases_monthly_average -- calculates average over no. active mos
            ,
            round(cast(
    ( total_amount_charged ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as amount_charged_monthly_average -- calculates average over no. active mos
            ,
            round(cast(
    ( total_amount_discounted ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as amount_discounted_monthly_average -- calculates average over no. active mos
            ,
            round(cast(
    ( total_amount_taxed ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as amount_taxed_monthly_average -- calculates average over no. active mos
            ,
            round(cast(
    ( total_net_spend ) / nullif( ( active_months ), 0)
 as numeric(28,6)), 2)
                as net_spend_monthly_average -- calculates average over no. active mos
            
    from enriched
)

select *
from aggs
