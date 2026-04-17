with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_books_tmp"

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
    
    accounting_book_extid
    
 , 
    cast(null as float) as 
    
    accounting_book_id
    
 , 
    cast(null as TEXT) as 
    
    accounting_book_name
    
 , 
    cast(null as float) as 
    
    base_book_id
    
 , 
    cast(null as timestamp) as 
    
    date_created
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as timestamp) as 
    
    date_last_modified
    
 , 
    cast(null as float) as 
    
    effective_period_id
    
 , 
    cast(null as TEXT) as 
    
    form_template_component_id
    
 , 
    cast(null as float) as 
    
    form_template_id
    
 , 
    cast(null as TEXT) as 
    
    is_adjustment_only
    
 , 
    cast(null as TEXT) as 
    
    is_arrangement_level_reclass
    
 , 
    cast(null as TEXT) as 
    
    is_consolidated
    
 , 
    cast(null as TEXT) as 
    
    is_contingent_revenue_handling
    
 , 
    cast(null as TEXT) as 
    
    is_include_child_subsidiaries
    
 , 
    cast(null as TEXT) as 
    
    is_primary
    
 , 
    cast(null as TEXT) as 
    
    is_two_step_revenue_allocation
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    unbilled_receivable_grouping
    
 


        
    from base
),

final as (
    
    select 
        accounting_book_id,
        is_primary,
        _fivetran_deleted

    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
