with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__items_tmp"

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    allow_drop_ship
    
 , 
    cast(null as float) as 
    
    alt_demand_source_item_id
    
 , 
    cast(null as float) as 
    
    asset_account_id
    
 , 
    cast(null as float) as 
    
    atp_lead_time
    
 , 
    cast(null as TEXT) as 
    
    atp_method
    
 , 
    cast(null as TEXT) as 
    
    available_to_partners
    
 , 
    cast(null as TEXT) as 
    
    avatax_taxcode
    
 , 
    cast(null as float) as 
    
    averagecost
    
 , 
    cast(null as float) as 
    
    backward_consumption_days
    
 , 
    cast(null as TEXT) as 
    
    build_sub_assemblies
    
 , 
    cast(null as float) as 
    
    class_id
    
 , 
    cast(null as float) as 
    
    code_of_supply_id
    
 , 
    cast(null as TEXT) as 
    
    commodity_code
    
 , 
    cast(null as float) as 
    
    consumption_unit_id
    
 , 
    cast(null as float) as 
    
    cost_0
    
 , 
    cast(null as TEXT) as 
    
    cost_category
    
 , 
    cast(null as TEXT) as 
    
    cost_estimate_type
    
 , 
    cast(null as TEXT) as 
    
    costing_method
    
 , 
    cast(null as TEXT) as 
    
    country_of_manufacture
    
 , 
    cast(null as TEXT) as 
    
    create_plan_on_event_type
    
 , 
    cast(null as timestamp) as 
    
    created
    
 , 
    cast(null as float) as 
    
    current_on_order_count
    
 , 
    cast(null as float) as 
    
    custreturn_variance_account_id
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as timestamp) as 
    
    date_last_modified
    
 , 
    cast(null as timestamp) as 
    
    date_of_last_transaction
    
 , 
    cast(null as float) as 
    
    default_return_cost
    
 , 
    cast(null as float) as 
    
    deferred_expense_account_id
    
 , 
    cast(null as float) as 
    
    deferred_revenue_account_id
    
 , 
    cast(null as TEXT) as 
    
    demand_source
    
 , 
    cast(null as float) as 
    
    demand_time_fence
    
 , 
    cast(null as float) as 
    
    department_id
    
 , 
    cast(null as TEXT) as 
    
    deposit
    
 , 
    cast(null as TEXT) as 
    
    displayname
    
 , 
    cast(null as TEXT) as 
    
    distribution_category
    
 , 
    cast(null as TEXT) as 
    
    distribution_network
    
 , 
    cast(null as float) as 
    
    dropship_expense_account_id
    
 , 
    cast(null as TEXT) as 
    
    effective_bom_control_type
    
 , 
    cast(null as float) as 
    
    expense_account_id
    
 , 
    cast(null as TEXT) as 
    
    featureddescription
    
 , 
    cast(null as TEXT) as 
    
    featureditem
    
 , 
    cast(null as float) as 
    
    fixed_lot_size
    
 , 
    cast(null as float) as 
    
    forward_consumption_days
    
 , 
    cast(null as TEXT) as 
    
    fraud_risk
    
 , 
    cast(null as TEXT) as 
    
    full_name
    
 , 
    cast(null as float) as 
    
    fx_adjustment_account_id
    
 , 
    cast(null as float) as 
    
    gain_loss_account_id
    
 , 
    cast(null as float) as 
    
    handling_cost
    
 , 
    cast(null as TEXT) as 
    
    hazmat
    
 , 
    cast(null as TEXT) as 
    
    hazmat_hazard_class
    
 , 
    cast(null as TEXT) as 
    
    hazmat_id
    
 , 
    cast(null as TEXT) as 
    
    hazmat_item_units
    
 , 
    cast(null as float) as 
    
    hazmat_item_units_qty
    
 , 
    cast(null as TEXT) as 
    
    hazmat_packing_group
    
 , 
    cast(null as TEXT) as 
    
    hazmat_shipping_name
    
 , 
    cast(null as TEXT) as 
    
    include_child_subsidiaries
    
 , 
    cast(null as float) as 
    
    income_account_id
    
 , 
    cast(null as float) as 
    
    interco_expense_account_id
    
 , 
    cast(null as float) as 
    
    interco_income_account_id
    
 , 
    cast(null as float) as 
    
    invt_count_classification
    
 , 
    cast(null as float) as 
    
    invt_count_interval
    
 , 
    cast(null as TEXT) as 
    
    is_cont_rev_handling
    
 , 
    cast(null as TEXT) as 
    
    is_enforce_min_qty_internally
    
 , 
    cast(null as TEXT) as 
    
    is_hold_rev_rec
    
 , 
    cast(null as TEXT) as 
    
    is_moss
    
 , 
    cast(null as TEXT) as 
    
    is_phantom
    
 , 
    cast(null as TEXT) as 
    
    is_special_order_item
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    isonline
    
 , 
    cast(null as TEXT) as 
    
    istaxable
    
 , 
    cast(null as float) as 
    
    item_defined_cost
    
 , 
    cast(null as TEXT) as 
    
    item_extid
    
 , 
    cast(null as float) as 
    
    item_id
    
 , 
    cast(null as float) as 
    
    item_image
    
 , 
    cast(null as TEXT) as 
    
    item_revenue_category
    
 , 
    cast(null as float) as 
    
    item_term_id
    
 , 
    cast(null as timestamp) as 
    
    last_cogs_correction
    
 , 
    cast(null as timestamp) as 
    
    last_invt_count_date
    
 , 
    cast(null as float) as 
    
    last_purchase_price
    
 , 
    cast(null as float) as 
    
    location_id
    
 , 
    cast(null as TEXT) as 
    
    lot_numbered_item
    
 , 
    cast(null as TEXT) as 
    
    lot_sizing_method
    
 , 
    cast(null as TEXT) as 
    
    manufacturer
    
 , 
    cast(null as TEXT) as 
    
    manufacturing_charge_item
    
 , 
    cast(null as TEXT) as 
    
    match_bill_to_receipt
    
 , 
    cast(null as TEXT) as 
    
    matrix_type
    
 , 
    cast(null as float) as 
    
    maximum_quantity
    
 , 
    cast(null as float) as 
    
    minimum_quantity
    
 , 
    cast(null as timestamp) as 
    
    modified
    
 , 
    cast(null as TEXT) as 
    
    mpn
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    nature_of_transaction_codes_id
    
 , 
    cast(null as timestamp) as 
    
    next_invt_count_date
    
 , 
    cast(null as float) as 
    
    ng_asset_type_id
    
 , 
    cast(null as float) as 
    
    ns_lead_time
    
 , 
    cast(null as TEXT) as 
    
    offersupport
    
 , 
    cast(null as TEXT) as 
    
    onspecial
    
 , 
    cast(null as TEXT) as 
    
    overhead_type
    
 , 
    cast(null as float) as 
    
    parent_id
    
 , 
    cast(null as float) as 
    
    payment_method_id
    
 , 
    cast(null as float) as 
    
    periodic_lot_size_days
    
 , 
    cast(null as TEXT) as 
    
    periodic_lot_size_type
    
 , 
    cast(null as float) as 
    
    pref_purchase_tax_id
    
 , 
    cast(null as float) as 
    
    pref_sale_tax_id
    
 , 
    cast(null as float) as 
    
    pref_stock_level
    
 , 
    cast(null as TEXT) as 
    
    prices_include_tax
    
 , 
    cast(null as float) as 
    
    pricing_group_id
    
 , 
    cast(null as TEXT) as 
    
    print_sub_items
    
 , 
    cast(null as float) as 
    
    prod_price_var_account_id
    
 , 
    cast(null as float) as 
    
    prod_qty_var_account_id
    
 , 
    cast(null as TEXT) as 
    
    prompt_payment_discount_item
    
 , 
    cast(null as float) as 
    
    purchase_price_var_account_id
    
 , 
    cast(null as float) as 
    
    purchase_unit_id
    
 , 
    cast(null as TEXT) as 
    
    purchasedescription
    
 , 
    cast(null as float) as 
    
    purchaseorderamount
    
 , 
    cast(null as float) as 
    
    purchaseorderquantity
    
 , 
    cast(null as float) as 
    
    purchaseorderquantitydiff
    
 , 
    cast(null as float) as 
    
    quantityavailable
    
 , 
    cast(null as float) as 
    
    quantitybackordered
    
 , 
    cast(null as float) as 
    
    quantityonhand
    
 , 
    cast(null as float) as 
    
    receiptamount
    
 , 
    cast(null as float) as 
    
    receiptquantity
    
 , 
    cast(null as float) as 
    
    receiptquantitydiff
    
 , 
    cast(null as float) as 
    
    reorder_multiple
    
 , 
    cast(null as float) as 
    
    reorderpoint
    
 , 
    cast(null as TEXT) as 
    
    replenishment_method
    
 , 
    cast(null as TEXT) as 
    
    resalable
    
 , 
    cast(null as float) as 
    
    reschedule_in_days
    
 , 
    cast(null as float) as 
    
    reschedule_out_days
    
 , 
    cast(null as float) as 
    
    rev_rec_forecast_rule_id
    
 , 
    cast(null as float) as 
    
    rev_rec_rule_id
    
 , 
    cast(null as TEXT) as 
    
    revenue_allocation_group
    
 , 
    cast(null as TEXT) as 
    
    round_up_as_component
    
 , 
    cast(null as float) as 
    
    safety_stock_days
    
 , 
    cast(null as float) as 
    
    safety_stock_level
    
 , 
    cast(null as float) as 
    
    sale_unit_id
    
 , 
    cast(null as TEXT) as 
    
    salesdescription
    
 , 
    cast(null as TEXT) as 
    
    salesforce_id
    
 , 
    cast(null as TEXT) as 
    
    salesprice
    
 , 
    cast(null as float) as 
    
    scrap_account_id
    
 , 
    cast(null as TEXT) as 
    
    serialized_item
    
 , 
    cast(null as float) as 
    
    shippingcost
    
 , 
    cast(null as TEXT) as 
    
    special_work_order_item
    
 , 
    cast(null as TEXT) as 
    
    specialsdescription
    
 , 
    cast(null as float) as 
    
    stock_unit_id
    
 , 
    cast(null as TEXT) as 
    
    storedescription
    
 , 
    cast(null as TEXT) as 
    
    storedetaileddescription
    
 , 
    cast(null as TEXT) as 
    
    storedisplayname
    
 , 
    cast(null as TEXT) as 
    
    subtype
    
 , 
    cast(null as TEXT) as 
    
    supplementary_unit__abberviat
    
 , 
    cast(null as float) as 
    
    supplementary_unit_id
    
 , 
    cast(null as float) as 
    
    supply_time_fence
    
 , 
    cast(null as TEXT) as 
    
    supply_type
    
 , 
    cast(null as float) as 
    
    tax_item_id
    
 , 
    cast(null as float) as 
    
    totalvalue
    
 , 
    cast(null as float) as 
    
    transferprice
    
 , 
    cast(null as TEXT) as 
    
    type_name
    
 , 
    cast(null as float) as 
    
    type_of_goods_id
    
 , 
    cast(null as TEXT) as 
    
    udf1
    
 , 
    cast(null as TEXT) as 
    
    udf2
    
 , 
    cast(null as TEXT) as 
    
    un_number
    
 , 
    cast(null as float) as 
    
    unbuild_variance_account_id
    
 , 
    cast(null as float) as 
    
    units_type_id
    
 , 
    cast(null as TEXT) as 
    
    upc_code
    
 , 
    cast(null as TEXT) as 
    
    use_component_yield
    
 , 
    cast(null as float) as 
    
    vendor_id
    
 , 
    cast(null as TEXT) as 
    
    vendorname
    
 , 
    cast(null as float) as 
    
    vendreturn_variance_account_id
    
 , 
    cast(null as TEXT) as 
    
    vsoe_deferral
    
 , 
    cast(null as TEXT) as 
    
    vsoe_delivered
    
 , 
    cast(null as TEXT) as 
    
    vsoe_discount
    
 , 
    cast(null as float) as 
    
    vsoe_price
    
 , 
    cast(null as float) as 
    
    weight
    
 , 
    cast(null as float) as 
    
    weight_in_user_defined_unit
    
 , 
    cast(null as float) as 
    
    weight_unit_index
    
 , 
    cast(null as float) as 
    
    wip_account_id
    
 , 
    cast(null as float) as 
    
    wip_cost_variance_account_id
    
 , 
    cast(null as float) as 
    
    work_order_lead_time
    
 


        
    from base
),

final as (
    
    select 
        item_id,
        name,
        type_name,
        salesdescription as sales_description,
        _fivetran_deleted

        --The below macro adds the fields defined within your items_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
