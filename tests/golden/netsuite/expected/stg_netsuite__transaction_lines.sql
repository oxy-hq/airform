with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__transaction_lines_tmp"

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        
    cast(null as float) as 
    
    account_id
    
 , 
    cast(null as float) as 
    
    amount
    
 , 
    cast(null as float) as 
    
    class_id
    
 , 
    cast(null as float) as 
    
    company_id
    
 , 
    cast(null as float) as 
    
    department_id
    
 , 
    cast(null as float) as 
    
    item_id
    
 , 
    cast(null as float) as 
    
    location_id
    
 , 
    cast(null as TEXT) as 
    
    memo
    
 , 
    cast(null as TEXT) as 
    
    non_posting_line
    
 , 
    cast(null as float) as 
    
    subsidiary_id
    
 , 
    cast(null as float) as 
    
    transaction_id
    
 , 
    cast(null as float) as 
    
    transaction_line_id
    
 


        
    from base
),

final as (
    
    select 
        transaction_id,
        transaction_line_id,
        subsidiary_id,
        account_id,
        company_id,
        item_id,
        amount,
        non_posting_line,
        class_id,
        location_id,
        department_id,
        memo

        --The below macro adds the fields defined within your transaction_lines_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
