with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__employees_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as float) as 
    
    approvallimit
    
 , 
    cast(null as integer) as 
    
    currency
    
 , 
    cast(null as integer) as 
    
    department
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    entityid
    
 , 
    cast(null as TEXT) as 
    
    expenselimit
    
 , 
    cast(null as TEXT) as 
    
    firstname
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    lastname
    
 , 
    cast(null as float) as 
    
    purchaseorderapprovallimit
    
 , 
    cast(null as float) as 
    
    purchaseorderlimit
    
 , 
    cast(null as integer) as 
    
    subsidiary
    
 , 
    cast(null as integer) as 
    
    supervisor
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as employee_id,
        entityid as entity_id,
        firstname as first_name,
        lastname as last_name,
        department as department_id,
        subsidiary as subsidiary_id,
        email,
        supervisor as supervisor_id,
        approvallimit as approval_limit,
        expenselimit as expense_limit,
        purchaseorderapprovallimit as purchase_order_approval_limit,
        purchaseorderlimit as purchase_order_limit,
        currency as currency_id,
        isinactive = 'T' as is_inactive
    from fields
)

select * 
from final
