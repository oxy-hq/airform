with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__vendor_types_tmp"

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
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as float) as 
    
    parent_id
    
 , 
    cast(null as TEXT) as 
    
    vendor_type_extid
    
 , 
    cast(null as float) as 
    
    vendor_type_id
    
 


        
    from base
),

final as (
    
    select 
        vendor_type_id,
        name,
        _fivetran_deleted

    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
