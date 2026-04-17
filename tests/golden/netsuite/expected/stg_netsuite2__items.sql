with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__items_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    fullname
    
 , 
    cast(null as TEXT) as 
    
    itemtype
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as integer) as 
    
    department
    
 , 
    cast(null as integer) as 
    
    class
    
 , 
    cast(null as integer) as 
    
    location
    
 , 
    cast(null as TEXT) as 
    
    subsidiary
    
 , 
    cast(null as integer) as 
    
    assetaccount
    
 , 
    cast(null as integer) as 
    
    expenseaccount
    
 , 
    cast(null as integer) as 
    
    gainlossaccount
    
 , 
    cast(null as integer) as 
    
    incomeaccount
    
 , 
    cast(null as integer) as 
    
    intercoexpenseaccount
    
 , 
    cast(null as integer) as 
    
    intercoincomeaccount
    
 , 
    cast(null as integer) as 
    
    deferralaccount
    
 , 
    cast(null as integer) as 
    
    deferredrevenueaccount
    
 , 
    cast(null as integer) as 
    
    parent
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as item_id,
        fullname as name,
        itemtype as type_name,
        description as sales_description,
        department as department_id,
        class as class_id,
        location as location_id,
        subsidiary as subsidiary_id,
        assetaccount as asset_account_id,
        expenseaccount as expense_account_id,
        gainlossaccount as gain_loss_account_id,
        incomeaccount as income_account_id,
        intercoexpenseaccount as interco_expense_account_id,
        intercoincomeaccount as interco_income_account_id,
        deferralaccount as deferred_expense_account_id,
        deferredrevenueaccount as deferred_revenue_account_id,
        parent as parent_item_id

        --The below macro adds the fields defined within your items_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
