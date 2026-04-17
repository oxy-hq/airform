with  __dbt__cte__int_recharge__customer_daily_rollup as (
with calendar as (
    select *
    from "recharge"."main_recharge"."int_recharge__calendar_spine"

), customers as (
    select
        source_relation,
        customer_id,
        customer_created_at
    from "recharge"."main_recharge"."recharge__customer_details"

), customers_dates as (
    select
        customers.source_relation,
        customers.customer_id,
        calendar.date_day,
        cast(date_trunc('week', calendar.date_day) as date) as date_week,
        cast(date_trunc('month', calendar.date_day) as date) as date_month,
        cast(date_trunc('year', calendar.date_day) as date) as date_year
    from calendar
    cross join customers
    where cast(date_trunc('day', customers.customer_created_at) as date) <= calendar.date_day
)

select *
from customers_dates
), spine as (
    select *
    from __dbt__cte__int_recharge__customer_daily_rollup

), billing as (
    select
        *,
        case when lower(order_type) = 'recurring' and lower(order_status) not in ('error', 'cancelled', 'queued')
            then charge_total_price - charge_total_refunds
            else 0 end as charge_recurring_net_amount,
        case when lower(order_type) = 'checkout' and lower(order_status) not in ('error', 'cancelled', 'queued')
            then charge_total_price - charge_total_refunds
            else 0 end as charge_one_time_net_amount,
        case when lower(order_type) = 'recurring' and lower(order_status) not in ('error', 'cancelled', 'queued')
            then calculated_order_total_price - calculated_order_total_refunds
            else 0 end as calculated_order_recurring_net_amount,
        case when lower(order_type) = 'checkout' and lower(order_status) not in ('error', 'cancelled', 'queued')
            then calculated_order_total_price - calculated_order_total_refunds
            else 0 end as calculated_order_one_time_net_amount
    from "recharge"."main_recharge"."recharge__billing_history"

), customers as (
    select
        source_relation,
        customer_id,
        first_charge_processed_at
    from "recharge"."main_recharge"."recharge__customer_details"

), aggs as (
    select
        spine.source_relation,
        spine.customer_id,
        spine.date_day,
        spine.date_week,
        spine.date_month,
        spine.date_year,
        count(billing.order_id) as no_of_orders,
        count(case when lower(billing.order_type) = 'recurring' then 1 else null end) as recurring_orders,
        count(case when lower(billing.order_type) = 'checkout' then 1 else null end) as one_time_orders,
        coalesce(sum(billing.charge_total_price), 0) as total_charges,
        
        
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.charge_total_price else 0 end) as numeric(28,6)), 2)
                as charge_total_price_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.charge_total_discounts else 0 end) as numeric(28,6)), 2)
                as charge_total_discounts_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.charge_total_tax else 0 end) as numeric(28,6)), 2)
                as charge_total_tax_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.charge_total_refunds else 0 end) as numeric(28,6)), 2)
                as charge_total_refunds_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.calculated_order_total_discounts else 0 end) as numeric(28,6)), 2)
                as calculated_order_total_discounts_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.calculated_order_total_tax else 0 end) as numeric(28,6)), 2)
                as calculated_order_total_tax_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.calculated_order_total_price else 0 end) as numeric(28,6)), 2)
                as calculated_order_total_price_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.calculated_order_total_refunds else 0 end) as numeric(28,6)), 2)
                as calculated_order_total_refunds_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.order_line_item_total else 0 end) as numeric(28,6)), 2)
                as order_line_item_total_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.order_item_quantity else 0 end) as numeric(28,6)), 2)
                as order_item_quantity_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.charge_recurring_net_amount else 0 end) as numeric(28,6)), 2)
                as charge_recurring_net_amount_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.charge_one_time_net_amount else 0 end) as numeric(28,6)), 2)
                as charge_one_time_net_amount_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.calculated_order_recurring_net_amount else 0 end) as numeric(28,6)), 2)
                as calculated_order_recurring_net_amount_realized
            ,
            round(cast(sum(case when lower(billing.order_status)  not in ('error', 'cancelled', 'queued')
                then billing.calculated_order_one_time_net_amount else 0 end) as numeric(28,6)), 2)
                as calculated_order_one_time_net_amount_realized
            
    from spine
    left join billing
        on cast(date_trunc('day', billing.order_processed_at) as date) = spine.date_day
        and billing.customer_id = spine.customer_id
        and billing.source_relation = spine.source_relation
    group by 1,2,3,4,5,6

), aggs_running as (
    select
        *,
        
            round(cast(sum(charge_total_price_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as charge_total_price_running_total
            ,
            round(cast(sum(charge_total_discounts_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as charge_total_discounts_running_total
            ,
            round(cast(sum(charge_total_tax_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as charge_total_tax_running_total
            ,
            round(cast(sum(charge_total_refunds_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as charge_total_refunds_running_total
            ,
            round(cast(sum(calculated_order_total_discounts_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as calculated_order_total_discounts_running_total
            ,
            round(cast(sum(calculated_order_total_tax_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as calculated_order_total_tax_running_total
            ,
            round(cast(sum(calculated_order_total_price_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as calculated_order_total_price_running_total
            ,
            round(cast(sum(calculated_order_total_refunds_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as calculated_order_total_refunds_running_total
            ,
            round(cast(sum(order_line_item_total_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as order_line_item_total_running_total
            ,
            round(cast(sum(order_item_quantity_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as order_item_quantity_running_total
            ,
            round(cast(sum(charge_recurring_net_amount_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as charge_recurring_net_amount_running_total
            ,
            round(cast(sum(charge_one_time_net_amount_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as charge_one_time_net_amount_running_total
            ,
            round(cast(sum(calculated_order_recurring_net_amount_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as calculated_order_recurring_net_amount_running_total
            ,
            round(cast(sum(calculated_order_one_time_net_amount_realized) over (partition by customer_id  order by date_day asc
                rows unbounded preceding) as numeric(28,6)), 2)
                as calculated_order_one_time_net_amount_running_total
            
    from aggs

), active_months as (
    select
        aggs_running.*,
        round(cast(date_diff('day', customers.first_charge_processed_at::timestamp, aggs_running.date_day::timestamp ) / 30
            as numeric(28,6)), 2)
            as active_months_to_date
    from aggs_running
    left join customers
        on customers.customer_id = aggs_running.customer_id
        and customers.source_relation = aggs_running.source_relation
)

select *
from active_months
