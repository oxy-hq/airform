with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__transactions_tmp"

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
    cast(null as float) as 
    
    accounting_period_id
    
 , 
    cast(null as float) as 
    
    currency_id
    
 , 
    cast(null as timestamp) as 
    
    due_date
    
 , 
    cast(null as TEXT) as 
    
    is_advanced_intercompany
    
 , 
    cast(null as TEXT) as 
    
    is_intercompany
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as timestamp) as 
    
    trandate
    
 , 
    cast(null as float) as 
    
    transaction_id
    
 , 
    cast(null as TEXT) as 
    
    transaction_type
    
 


        
    from base
),

final as (
    
    select 
        transaction_id,
        status,
        trandate as transaction_date,
        currency_id,
        accounting_period_id,
        due_date as due_date_at,
        transaction_type,
        is_intercompany,
        is_advanced_intercompany,
        _fivetran_deleted

        --The below macro adds the fields defined within your transactions_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
