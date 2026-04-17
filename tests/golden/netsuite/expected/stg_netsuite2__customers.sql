with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__customers_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    entityid
    
 , 
    cast(null as TEXT) as 
    
    externalid
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as TEXT) as 
    
    isperson
    
 , 
    cast(null as TEXT) as 
    
    altname
    
 , 
    cast(null as TEXT) as 
    
    companyname
    
 , 
    cast(null as TEXT) as 
    
    firstname
    
 , 
    cast(null as TEXT) as 
    
    lastname
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    phone
    
 , 
    cast(null as integer) as 
    
    defaultbillingaddress
    
 , 
    cast(null as integer) as 
    
    defaultshippingaddress
    
 , 
    cast(null as integer) as 
    
    receivablesaccount
    
 , 
    cast(null as integer) as 
    
    currency
    
 , 
    cast(null as timestamp) as 
    
    firstorderdate
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as customer_id,
        entityid as entity_id,
        externalid as customer_external_id,
        parent as parent_id,
        isperson = 'T' as is_person,
        altname as alt_name,
        companyname as company_name,
        firstname as first_name,
        lastname as last_name,
        email as email_address,
        phone as phone_number,
        defaultbillingaddress as default_billing_address_id,
        defaultshippingaddress as default_shipping_address_id,
        receivablesaccount as receivables_account_id,
        currency as currency_id,
        cast(firstorderdate as date) as date_first_order_at

        --The below macro adds the fields defined within your customers_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
