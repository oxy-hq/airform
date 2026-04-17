with charge_line_items as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge_line_item"

), charges as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge"

), charge_shipping_lines as (

    select
        source_relation,
        charge_id,
        sum(price) as total_shipping
    from "recharge"."main_recharge_source"."stg_recharge__charge_shipping_line"
    group by 1, 2



), addresses as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__address"

), customers as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__customer"

), subscriptions as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__subscription_history"
    where is_most_recent_record

), enhanced as (
    select
        charge_line_items.source_relation,
        cast(charge_line_items.charge_id as TEXT) as header_id,
        cast(charge_line_items.index as TEXT) as line_item_id,
        row_number() over (partition by charge_line_items.charge_id 
            order by charge_line_items.index) as line_item_index,

        -- header level fields
        charges.charge_created_at as created_at,
        charges.charge_status as header_status,
        cast(charges.total_discounts as numeric(28,6)) as discount_amount,
        cast(charges.total_refunds as numeric(28,6)) as refund_amount,
        cast(charge_shipping_lines.total_shipping as numeric(28,6)) as fee_amount,
        addresses.payment_method_id,
        charges.external_transaction_id_payment_processor as payment_id,
        charges.payment_processor as payment_method,
        charges.charge_processed_at as payment_at,
        charges.charge_type as billing_type,  -- possible values: checkout, recurring

        -- Currency is in the Charges api object but not the Fivetran schema, so relying on Checkouts for now.
        -- Checkouts has only 20% utilization, so we should switch to the Charges field when it is added.
        cast(null as TEXT) as currency,

        -- line item level fields
        cast(charge_line_items.purchase_item_type as TEXT) as transaction_type, -- possible values: subscription, onetime
        cast(charge_line_items.external_product_id_ecommerce as TEXT) as product_id,
        cast(charge_line_items.title as TEXT) as product_name,
        cast(null as TEXT) as product_type, -- product_type not available
        cast(charge_line_items.quantity as integer) as quantity,
        cast(charge_line_items.unit_price as numeric(28,6)) as unit_amount,
        cast(charge_line_items.tax_due as numeric(28,6)) as tax_amount,
        cast(charge_line_items.total_price as numeric(28,6)) as total_amount,
        case when charge_line_items.purchase_item_type = 'subscription'
            then cast(charge_line_items.purchase_item_id as TEXT)
            end as subscription_id,
        subscriptions.product_title as subscription_plan,
        subscriptions.subscription_created_at as subscription_period_started_at,
        subscriptions.subscription_cancelled_at as subscription_period_ended_at,
        cast(subscriptions.subscription_status as TEXT) as subscription_status,
        'customer' as customer_level,
        cast(charges.customer_id as TEXT) as customer_id,
        cast(customers.customer_created_at as timestamp) as customer_created_at,
        -- coalesces are since information may be incomplete in various tables and casts for consistency
        coalesce(
            cast(charges.email as TEXT),
            cast(customers.email as TEXT)
            ) as customer_email,
        coalesce(
            customers.billing_first_name || ' ' || customers.billing_last_name,
            addresses.first_name || ' ' || addresses.last_name
            ) as customer_name,
        coalesce(cast(customers.billing_company as TEXT),
            cast(addresses.company as TEXT)
            ) as customer_company,
        coalesce(cast(customers.billing_city as TEXT),
            cast(addresses.city as TEXT)
            ) as customer_city,
        coalesce(cast(customers.billing_country as TEXT),
            cast(addresses.country as TEXT)
            ) as customer_country

    from charge_line_items

    left join charges
        on charges.charge_id = charge_line_items.charge_id
        and charges.source_relation = charge_line_items.source_relation

    left join addresses
        on addresses.address_id = charges.address_id
        and addresses.source_relation = charges.source_relation

    left join customers
        on customers.customer_id = charges.customer_id
        and customers.source_relation = charges.source_relation

    

    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = charges.charge_id
        and charge_shipping_lines.source_relation = charges.source_relation

    left join subscriptions
        on subscriptions.subscription_id = charge_line_items.purchase_item_id
        and subscriptions.source_relation = charge_line_items.source_relation

), final as (

    -- line item level
    select
        source_relation,
        header_id,
        line_item_id,
        line_item_index,
        'line_item' as record_type,
        created_at,
        currency,
        header_status,
        product_id,
        product_name,
        transaction_type,
        billing_type,
        product_type,
        quantity,
        unit_amount,
        cast(null as numeric(28,6)) as discount_amount,
        tax_amount,
        total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        cast(null as numeric(28,6)) as fee_amount,
        cast(null as numeric(28,6)) as refund_amount,
        subscription_id,
        subscription_plan,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_created_at,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced

    union all

    -- header level
    select
        source_relation,
        header_id,
        cast(null as TEXT) as line_item_id,
        cast(0 as integer) as line_item_index,
        'header' as record_type,
        created_at,
        currency,
        header_status,
        cast(null as TEXT) as product_id,
        cast(null as TEXT) as product_name,
        cast(null as TEXT) as transaction_type,
        billing_type,
        cast(null as TEXT) as product_type,
        cast(null as integer) as quantity,
        cast(null as numeric(28,6)) as unit_amount,
        discount_amount,
        cast(null as numeric(28,6)) as tax_amount,
        cast(null as numeric(28,6)) as total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        fee_amount,
        refund_amount,
        cast(null as TEXT) as subscription_id,
        cast(null as TEXT) as subscription_plan,
        cast(null as timestamp) as subscription_period_started_at,
        cast(null as timestamp) as subscription_period_ended_at,
        cast(null as TEXT) as subscription_status,
        customer_id,
        customer_created_at,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced
    where line_item_index = 1
)

select *
from final
