with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite__locations_tmp"

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
    
    city
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as TEXT) as 
    
    full_name
    
 , 
    cast(null as float) as 
    
    location_id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 


        
    from base
),

final as (
    
    select 
        location_id,
        name,
        full_name,
        city,
        country,
        _fivetran_deleted

        --The below macro adds the fields defined within your locations_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
