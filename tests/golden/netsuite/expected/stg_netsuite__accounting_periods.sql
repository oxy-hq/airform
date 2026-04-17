with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_periods_tmp"

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
    cast(null as TEXT) as 
    
    _fivetran_id
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as float) as 
    
    accounting_period_id
    
 , 
    cast(null as TEXT) as 
    
    closed
    
 , 
    cast(null as TEXT) as 
    
    closed_accounts_payable
    
 , 
    cast(null as TEXT) as 
    
    closed_accounts_receivable
    
 , 
    cast(null as TEXT) as 
    
    closed_all
    
 , 
    cast(null as timestamp) as 
    
    closed_on
    
 , 
    cast(null as TEXT) as 
    
    closed_payroll
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as timestamp) as 
    
    date_last_modified
    
 , 
    cast(null as timestamp) as 
    
    ending
    
 , 
    cast(null as float) as 
    
    fiscal_calendar_id
    
 , 
    cast(null as TEXT) as 
    
    fivetran_index
    
 , 
    cast(null as TEXT) as 
    
    full_name
    
 , 
    cast(null as TEXT) as 
    
    is_adjustment
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    locked_accounts_payable
    
 , 
    cast(null as TEXT) as 
    
    locked_accounts_receivable
    
 , 
    cast(null as TEXT) as 
    
    locked_all
    
 , 
    cast(null as TEXT) as 
    
    locked_payroll
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    parent_id
    
 , 
    cast(null as TEXT) as 
    
    quarter
    
 , 
    cast(null as timestamp) as 
    
    starting
    
 , 
    cast(null as TEXT) as 
    
    year_0
    
 , 
    cast(null as float) as 
    
    year_id
    
 


        
    from base
),

final as (
    
    select 
        accounting_period_id,
        name,
        full_name,
        fiscal_calendar_id,
        year_id,
        starting as starting_at,
        ending as ending_at,
        quarter,
        year_0,
        is_adjustment,
        closed as is_closed,
        _fivetran_deleted

        --The below macro adds the fields defined within your accounting_periods_pass_through_columns variable into the staging model
        






        
    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
