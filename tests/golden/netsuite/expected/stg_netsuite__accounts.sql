with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounts_tmp"

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
    
    account_id
    
 , 
    cast(null as TEXT) as 
    
    accountnumber
    
 , 
    cast(null as TEXT) as 
    
    general_rate_type
    
 , 
    cast(null as TEXT) as 
    
    is_balancesheet
    
 , 
    cast(null as TEXT) as 
    
    is_leftside
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    parent_id
    
 , 
    cast(null as TEXT) as 
    
    type_name
    
 


        
    from base
),

final as (
    
    select 
        account_id,
        parent_id,
        name,
        type_name,
        accountnumber as account_number,
        general_rate_type,
        is_leftside,
        is_balancesheet,
        _fivetran_deleted

        --The below macro adds the fields defined within your accounts_pass_through_columns variable into the staging model
        






        
    from fields
)

select * 
from final
