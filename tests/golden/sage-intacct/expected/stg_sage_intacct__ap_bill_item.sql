with base as (

    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__ap_bill_item_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    accountkey
    
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
    cast(null as integer) as 
    
    baselocation
    
 , 
    cast(null as boolean) as 
    
    billable
    
 , 
    cast(null as boolean) as 
    
    billed
    
 , 
    cast(null as TEXT) as 
    
    classid
    
 , 
    cast(null as TEXT) as 
    
    classname
    
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
    
    departmentid
    
 , 
    cast(null as TEXT) as 
    
    departmentname
    
 , 
    cast(null as date) as 
    
    entry_date
    
 , 
    cast(null as TEXT) as 
    
    entrydescription
    
 , 
    cast(null as integer) as 
    
    exchange_rate
    
 , 
    cast(null as TEXT) as 
    
    itemid
    
 , 
    cast(null as TEXT) as 
    
    itemname
    
 , 
    cast(null as integer) as 
    
    line_no
    
 , 
    cast(null as boolean) as 
    
    lineitem
    
 , 
    cast(null as TEXT) as 
    
    locationid
    
 , 
    cast(null as TEXT) as 
    
    locationname
    
 , 
    cast(null as integer) as 
    
    offsetglaccountno
    
 , 
    cast(null as TEXT) as 
    
    offsetglaccounttitle
    
 , 
    cast(null as TEXT) as 
    
    projectid
    
 , 
    cast(null as TEXT) as 
    
    projectname
    
 , 
    cast(null as TEXT) as 
    
    recordkey
    
 , 
    cast(null as TEXT) as 
    
    recordno
    
 , 
    cast(null as TEXT) as 
    
    recordtype
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as float) as 
    
    totalpaid
    
 , 
    cast(null as float) as 
    
    totalselected
    
 , 
    cast(null as TEXT) as 
    
    vendorid
    
 , 
    cast(null as TEXT) as 
    
    vendorname
    
 , 
    cast(null as timestamp) as 
    
    whencreated
    
 , 
    cast(null as timestamp) as 
    
    whenmodified
    
 


        
, 'sage_intacct' || '.'|| 'sage_intacct_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        cast(recordkey as TEXT) as bill_id,
        cast(recordno as TEXT) as bill_item_id,
        _fivetran_synced,
        accountkey as account_key,
        accountno as account_no,
        accounttitle as account_title,
        amount, 
        basecurr as base_curr,
        baselocation as base_location,
        billable, 
        billed,
        cast(classid as TEXT) as class_id,
        classname as class_name,
        createdby as created_by,
        currency,
        customerid as customer_id,
        customername as customer_name,
        cast(departmentid as TEXT) as department_id,
        departmentname as department_name,
        entry_date as entry_date_at,
        entrydescription as entry_description,
        exchange_rate,
        cast(itemid as TEXT) as item_id,
        itemname as item_name,
        line_no,
        lineitem as line_item,
        cast(locationid as TEXT) as location_id,
        locationname as location_name,
        offsetglaccountno as offset_gl_account_no,
        offsetglaccounttitle as offset_gl_account_title,
        recordtype as record_type,
        state,
        totalpaid as total_item_paid,
        totalselected as total_selected,
        vendorid as vendor_id,
        vendorname as vendor_name,
        whencreated as created_at,
        whenmodified as modified_at,
        projectname as project_name,
        projectid as project_id

    from fields

)

select * 
from final
