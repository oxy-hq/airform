with base as (

    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__gl_detail_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as float) as 
    
    accountno
    
 , 
    cast(null as TEXT) as 
    
    accounttitle
    
 , 
    cast(null as float) as 
    
    amount
    
 , 
    cast(null as TEXT) as 
    
    basecurr
    
 , 
    cast(null as date) as 
    
    batch_date
    
 , 
    cast(null as integer) as 
    
    batch_no
    
 , 
    cast(null as TEXT) as 
    
    batch_title
    
 , 
    cast(null as TEXT) as 
    
    batchkey
    
 , 
    cast(null as TEXT) as 
    
    bookid
    
 , 
    cast(null as TEXT) as 
    
    classid
    
 , 
    cast(null as TEXT) as 
    
    classname
    
 , 
    cast(null as float) as 
    
    creditamount
    
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
    cast(null as float) as 
    
    debitamount
    
 , 
    cast(null as TEXT) as 
    
    departmentid
    
 , 
    cast(null as TEXT) as 
    
    departmenttitle
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as TEXT) as 
    
    docnumber
    
 , 
    cast(null as TEXT) as 
    
    document
    
 , 
    cast(null as date) as 
    
    entry_date
    
 , 
    cast(null as TEXT) as 
    
    entry_state
    
 , 
    cast(null as TEXT) as 
    
    entrydescription
    
 , 
    cast(null as integer) as 
    
    line_no
    
 , 
    cast(null as TEXT) as 
    
    locationid
    
 , 
    cast(null as TEXT) as 
    
    locationname
    
 , 
    cast(null as timestamp) as 
    
    modified
    
 , 
    cast(null as TEXT) as 
    
    prdescription
    
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
    cast(null as float) as 
    
    totaldue
    
 , 
    cast(null as float) as 
    
    totalentered
    
 , 
    cast(null as float) as 
    
    totalpaid
    
 , 
    cast(null as integer) as 
    
    tr_type
    
 , 
    cast(null as float) as 
    
    trx_amount
    
 , 
    cast(null as float) as 
    
    trx_creditamount
    
 , 
    cast(null as float) as 
    
    trx_debitamount
    
 , 
    cast(null as TEXT) as 
    
    vendorid
    
 , 
    cast(null as TEXT) as 
    
    vendorname
    
 , 
    cast(null as date) as 
    
    whencreated
    
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
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 


        
, 'sage_intacct' || '.'|| 'sage_intacct_integration_tests' as source_relation

        --The below script allows for pass through columns.
        

    from base
),

final as (

    select
        source_relation,
        recordno as gl_detail_id,
        cast(accountno as TEXT) as account_no,
        accounttitle as account_title,
        amount,
        batch_date,
        batch_no,
        batch_title,
        batchkey as batch_key,
        bookid as book_id,
        classid as class_id,
        classname as class_name,
        creditamount as credit_amount,
        debitamount as debit_amount,
        currency,
        customerid as customer_id,
        customername as customer_name,
        departmentid as department_id,
        departmenttitle as department_title,
        description,
        docnumber as doc_number,
        entry_date as entry_date_at,
        entry_state,
        entrydescription as entry_description,
        line_no,
        locationid as location_id,
        locationname as location_name,
        prdescription as pr_description,
        recordid as record_id,
        recordtype as record_type,
        totaldue as total_due,
        totalentered as total_entered,
        totalpaid as total_paid,
        tr_type,
        trx_amount,
        trx_creditamount as trx_credit_amount,
        trx_debitamount as trx_debit_amount,
        vendorid as vendor_id,
        vendorname as vendor_name,
        whencreated as created_at,
        whendue as due_at,
        whenmodified as modified_at,
        whenpaid as paid_at,
        _fivetran_deleted as is_detail_deleted


        --The below script allows for pass through columns.
        

    from fields
)

select * 
from final
