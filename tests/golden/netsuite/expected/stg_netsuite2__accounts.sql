with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__accounts_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    externalid
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as TEXT) as 
    
    acctnumber
    
 , 
    cast(null as TEXT) as 
    
    accttype
    
 , 
    cast(null as TEXT) as 
    
    sspecacct
    
 , 
    cast(null as TEXT) as 
    
    fullname
    
 , 
    cast(null as TEXT) as 
    
    accountsearchdisplaynamecopy
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as integer) as 
    
    deferralacct
    
 , 
    cast(null as TEXT) as 
    
    cashflowrate
    
 , 
    cast(null as TEXT) as 
    
    generalrate
    
 , 
    cast(null as integer) as 
    
    currency
    
 , 
    cast(null as integer) as 
    
    class
    
 , 
    cast(null as integer) as 
    
    department
    
 , 
    cast(null as integer) as 
    
    location
    
 , 
    cast(null as TEXT) as 
    
    includechildren
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    issummary
    
 , 
    cast(null as TEXT) as 
    
    eliminate
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as account_id, 
        externalid as account_external_id,
        parent as parent_id,
        acctnumber as account_number,
        accttype as account_type_id,
        sspecacct as special_account_type_id,
        fullname as name,
        accountsearchdisplaynamecopy as display_name,
        description as account_description,
        deferralacct as deferral_account_id,
        cashflowrate as cash_flow_rate_type,
        generalrate as general_rate_type,
        currency as currency_id,
        class as class_id,
        department as department_id,
        location as location_id,
        includechildren = 'T' as is_including_child_subs,
        isinactive = 'T' as is_inactive,
        issummary = 'T' as is_summary,
        eliminate = 'T' as is_eliminate,
        _fivetran_deleted

        --The below macro adds the fields defined within your accounts_pass_through_columns variable into the staging model
        







        
    from fields
)

select * 
from final
