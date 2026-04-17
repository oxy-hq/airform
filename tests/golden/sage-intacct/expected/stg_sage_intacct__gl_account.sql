with base as (

    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__gl_account_tmp"

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
    
    accountno
    
 , 
    cast(null as TEXT) as 
    
    accounttype
    
 , 
    cast(null as TEXT) as 
    
    alternativeaccount
    
 , 
    cast(null as TEXT) as 
    
    category
    
 , 
    cast(null as integer) as 
    
    categorykey
    
 , 
    cast(null as integer) as 
    
    closetoacctkey
    
 , 
    cast(null as integer) as 
    
    closingaccountno
    
 , 
    cast(null as TEXT) as 
    
    closingaccounttitle
    
 , 
    cast(null as TEXT) as 
    
    closingtype
    
 , 
    cast(null as integer) as 
    
    createdby
    
 , 
    cast(null as integer) as 
    
    modifiedby
    
 , 
    cast(null as TEXT) as 
    
    normalbalance
    
 , 
    cast(null as integer) as 
    
    recordno
    
 , 
    cast(null as boolean) as 
    
    requireclass
    
 , 
    cast(null as boolean) as 
    
    requirecustomer
    
 , 
    cast(null as boolean) as 
    
    requiredept
    
 , 
    cast(null as boolean) as 
    
    requireemployee
    
 , 
    cast(null as boolean) as 
    
    requireitem
    
 , 
    cast(null as boolean) as 
    
    requireloc
    
 , 
    cast(null as boolean) as 
    
    requireproject
    
 , 
    cast(null as boolean) as 
    
    requirevendor
    
 , 
    cast(null as boolean) as 
    
    requirewarehouse
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as boolean) as 
    
    taxable
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as timestamp) as 
    
    whencreated
    
 , 
    cast(null as timestamp) as 
    
    whenmodified
    
 


        
, 'sage_intacct' || '.'|| 'sage_intacct_integration_tests' as source_relation

        --The below script allows for pass through columns.
        

    from base
),

final as (

    select
        source_relation,
        cast(accountno as TEXT) as account_no,
        _fivetran_deleted,	
        _fivetran_synced,	
        accounttype as account_type,	
        alternativeaccount as alternative_account,	
        category,	
        categorykey as category_key,	
        closetoacctkey as close_to_acct_key,	
        closingaccountno as closing_account_no,	
        closingaccounttitle as closing_account_title,	
        closingtype as closing_type,	
        createdby as created_by,	
        modifiedby as modified_by,	
        normalbalance as normal_balance,	
        recordno as gl_account_id,	
        status,	
        taxable,	
        title,	
        whencreated as created_at,	
        whenmodified as modified_at	

        --The below script allows for pass through columns.
        

    from fields
)

select * 
from final
