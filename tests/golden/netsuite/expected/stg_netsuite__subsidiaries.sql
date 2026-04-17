with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__subsidiaries_tmp"

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
    
    address
    
 , 
    cast(null as TEXT) as 
    
    address1
    
 , 
    cast(null as TEXT) as 
    
    address2
    
 , 
    cast(null as float) as 
    
    base_currency_id
    
 , 
    cast(null as TEXT) as 
    
    branch_id
    
 , 
    cast(null as TEXT) as 
    
    brn
    
 , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as timestamp) as 
    
    date_last_modified
    
 , 
    cast(null as TEXT) as 
    
    edition
    
 , 
    cast(null as TEXT) as 
    
    federal_number
    
 , 
    cast(null as float) as 
    
    fiscal_calendar_id
    
 , 
    cast(null as TEXT) as 
    
    full_name
    
 , 
    cast(null as TEXT) as 
    
    is_elimination
    
 , 
    cast(null as TEXT) as 
    
    is_moss
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    isinactive_bool
    
 , 
    cast(null as TEXT) as 
    
    legal_name
    
 , 
    cast(null as float) as 
    
    moss_nexus_id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    parent_id
    
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
    
    receiptamount
    
 , 
    cast(null as float) as 
    
    receiptquantity
    
 , 
    cast(null as float) as 
    
    receiptquantitydiff
    
 , 
    cast(null as TEXT) as 
    
    return_address
    
 , 
    cast(null as TEXT) as 
    
    return_address1
    
 , 
    cast(null as TEXT) as 
    
    return_address2
    
 , 
    cast(null as TEXT) as 
    
    return_city
    
 , 
    cast(null as TEXT) as 
    
    return_country
    
 , 
    cast(null as TEXT) as 
    
    return_state
    
 , 
    cast(null as TEXT) as 
    
    return_zipcode
    
 , 
    cast(null as TEXT) as 
    
    shipping_address
    
 , 
    cast(null as TEXT) as 
    
    shipping_address1
    
 , 
    cast(null as TEXT) as 
    
    shipping_address2
    
 , 
    cast(null as TEXT) as 
    
    shipping_city
    
 , 
    cast(null as TEXT) as 
    
    shipping_country
    
 , 
    cast(null as TEXT) as 
    
    shipping_state
    
 , 
    cast(null as TEXT) as 
    
    shipping_zipcode
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as TEXT) as 
    
    state_tax_number
    
 , 
    cast(null as float) as 
    
    subnav__searchable_subsidiary
    
 , 
    cast(null as TEXT) as 
    
    subsidiary_extid
    
 , 
    cast(null as float) as 
    
    subsidiary_id
    
 , 
    cast(null as float) as 
    
    taxonomy_reference_id
    
 , 
    cast(null as TEXT) as 
    
    tran_num_prefix
    
 , 
    cast(null as TEXT) as 
    
    uen
    
 , 
    cast(null as TEXT) as 
    
    url
    
 , 
    cast(null as TEXT) as 
    
    zipcode
    
 


        
    from base
),

final as (
    
    select 
        subsidiary_id,
        fiscal_calendar_id,
        full_name,
        name,
        parent_id,
        _fivetran_deleted

        --The below macro adds the fields defined within your subsidiaries_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
