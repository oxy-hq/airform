with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_period_fiscal_cal_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_id
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    accountingperiod
    
 , 
    cast(null as integer) as 
    
    fiscalcalendar
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as TEXT) as 
    
    fullname
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation, 
        _fivetran_id,
        _fivetran_synced,
        accountingperiod as accounting_period_id,
        fiscalcalendar as fiscal_calendar_id,
        fullname as accounting_period_full_name,
        parent as parent_id
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
