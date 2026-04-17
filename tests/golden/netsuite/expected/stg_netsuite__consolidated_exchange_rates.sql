with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__consolidated_exchange_rates_tmp"

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
    cast(null as float) as 
    
    accounting_book_id
    
 , 
    cast(null as float) as 
    
    accounting_period_id
    
 , 
    cast(null as float) as 
    
    average_budget_rate
    
 , 
    cast(null as float) as 
    
    average_rate
    
 , 
    cast(null as float) as 
    
    consolidated_exchange_rate_id
    
 , 
    cast(null as float) as 
    
    current_budget_rate
    
 , 
    cast(null as float) as 
    
    current_rate
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as float) as 
    
    from_subsidiary_id
    
 , 
    cast(null as float) as 
    
    historical_budget_rate
    
 , 
    cast(null as float) as 
    
    historical_rate
    
 , 
    cast(null as float) as 
    
    to_subsidiary_id
    
 


        
    from base
),

final as (
    
    select 
        consolidated_exchange_rate_id,
        accounting_book_id,
        accounting_period_id,
        average_rate,
        current_rate,
        historical_rate,
        from_subsidiary_id,
        to_subsidiary_id,
        _fivetran_deleted

        --The below macro adds the fields defined within your consolidated_exchange_rates_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
