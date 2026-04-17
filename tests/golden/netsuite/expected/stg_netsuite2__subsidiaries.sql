with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__subsidiaries_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    fullname
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as integer) as 
    
    mainaddress
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as integer) as 
    
    fiscalcalendar
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as TEXT) as 
    
    iselimination
    
 , 
    cast(null as integer) as 
    
    currency
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as subsidiary_id,
        name,
        fullname as full_name,
        email as email_address,
        mainaddress as main_address_id,
        country,
        state,
        fiscalcalendar as fiscal_calendar_id,
        parent as parent_id,
        iselimination = 'T' as is_elimination,
        currency as currency_id

        --The below macro adds the fields defined within your subsidiaries_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
