with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_periods_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    alllocked
    
 , 
    cast(null as TEXT) as 
    
    allownonglchanges
    
 , 
    cast(null as TEXT) as 
    
    aplocked
    
 , 
    cast(null as TEXT) as 
    
    arlocked
    
 , 
    cast(null as TEXT) as 
    
    closed
    
 , 
    cast(null as timestamp) as 
    
    closedondate
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as timestamp) as 
    
    enddate
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    isadjust
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    isposting
    
 , 
    cast(null as TEXT) as 
    
    isquarter
    
 , 
    cast(null as TEXT) as 
    
    isyear
    
 , 
    cast(null as timestamp) as 
    
    lastmodifieddate
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as TEXT) as 
    
    periodname
    
 , 
    cast(null as timestamp) as 
    
    startdate
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as accounting_period_id,
        parent as parent_id, 
        periodname as name,
        cast(startdate as date) as starting_at,
        cast(enddate as date) as ending_at,
        closedondate as closed_at,
        isquarter = 'T' as is_quarter,
        isyear = 'T' as is_year,
        isadjust = 'T' as is_adjustment,
        isposting = 'T' as is_posting,
        closed = 'T' as is_closed,
        alllocked = 'T' as is_all_locked,
        arlocked = 'T' as is_ar_locked,
        aplocked = 'T' as is_ap_locked

        --The below macro adds the fields defined within your accounting_periods_pass_through_columns variable into the staging model
        







        
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
