with base as (

    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__ar_invoice_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    auwhencreated
    
 , 
    cast(null as TEXT) as 
    
    basecurr
    
 , 
    cast(null as TEXT) as 
    
    billtopaytocontactname
    
 , 
    cast(null as integer) as 
    
    billtopaytokey
    
 , 
    cast(null as integer) as 
    
    createdby
    
 , 
    cast(null as TEXT) as 
    
    currency
    
 , 
    cast(null as TEXT) as 
    
    customerid
    
 , 
    cast(null as TEXT) as 
    
    customername
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as TEXT) as 
    
    docnumber
    
 , 
    cast(null as integer) as 
    
    due_in_days
    
 , 
    cast(null as TEXT) as 
    
    megaentityid
    
 , 
    cast(null as TEXT) as 
    
    megaentityname
    
 , 
    cast(null as TEXT) as 
    
    recordid
    
 , 
    cast(null as TEXT) as 
    
    recordno
    
 , 
    cast(null as TEXT) as 
    
    recordtype
    
 , 
    cast(null as TEXT) as 
    
    shiptoreturntocontactname
    
 , 
    cast(null as integer) as 
    
    shiptoreturntokey
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as float) as 
    
    totaldue
    
 , 
    cast(null as float) as 
    
    totalentered
    
 , 
    cast(null as float) as 
    
    totalpaid
    
 , 
    cast(null as date) as 
    
    whencreated
    
 , 
    cast(null as date) as 
    
    whendiscount
    
 , 
    cast(null as date) as 
    
    whendue
    
 , 
    cast(null as timestamp) as 
    
    whenmodified
    
 , 
    cast(null as date) as 
    
    whenpaid
    
 , 
    cast(null as date) as 
    
    whenposted
    
 


        
, 'sage_intacct' || '.'|| 'sage_intacct_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        cast(recordno as TEXT) as invoice_id,
        _fivetran_deleted,
        _fivetran_synced,
        auwhencreated as au_created_at,
        billtopaytocontactname as bill_to_pay_to_contact_name,
        billtopaytokey as bill_to_pay_to_key,
        createdby as created_by,
        currency,
        customerid as customer_id,
        customername as customer_name,
        description,
        docnumber as doc_number,
        due_in_days as due_in_days,
        megaentityid as mega_entity_id,
        megaentityname as mega_entity_name,
        recordid as record_id,
        recordtype as record_type,
        shiptoreturntocontactname as ship_to_return_to_contact_name,
        shiptoreturntokey as ship_to_return_to_key,
        state,
        totaldue as total_due,
        totalentered as total_entered,
        totalpaid as total_paid,
        whencreated as created_at,
        whendue as due_at,
        whenmodified as modified_at,
        whenpaid as paid_at,
        whenposted as posted_at

    from fields
)

select * from final
where not coalesce(_fivetran_deleted, false)
