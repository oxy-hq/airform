with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transactions_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    transactionnumber
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as TEXT) as 
    
    memo
    
 , 
    cast(null as timestamp) as 
    
    trandate
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as integer) as 
    
    createdby
    
 , 
    cast(null as timestamp) as 
    
    createddate
    
 , 
    cast(null as timestamp) as 
    
    duedate
    
 , 
    cast(null as timestamp) as 
    
    closedate
    
 , 
    cast(null as integer) as 
    
    currency
    
 , 
    cast(null as integer) as 
    
    entity
    
 , 
    cast(null as integer) as 
    
    lastmodifiedby
    
 , 
    cast(null as integer) as 
    
    postingperiod
    
 , 
    cast(null as TEXT) as 
    
    posting
    
 , 
    cast(null as integer) as 
    
    nexus
    
 , 
    cast(null as TEXT) as 
    
    taxregoverride
    
 , 
    cast(null as TEXT) as 
    
    taxdetailsoverride
    
 , 
    cast(null as timestamp) as 
    
    taxpointdate
    
 , 
    cast(null as TEXT) as 
    
    taxpointdateoverride
    
 , 
    cast(null as TEXT) as 
    
    intercoadj
    
 , 
    cast(null as TEXT) as 
    
    isreversal
    
 , 
    cast(null as integer) as 
    
    reversal
    
 , 
    cast(null as timestamp) as 
    
    reversaldate
    
 , 
    cast(null as TEXT) as 
    
    reversaldefer
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(_fivetran_synced as date) as _fivetran_synced_date,
        id as transaction_id,
        transactionnumber as transaction_number,
        type as transaction_type,
        memo,
        cast(trandate as date) as transaction_date,
        status,
        createddate as created_at,
        cast(duedate as date) as due_date_at,
        cast(closedate as date) as closed_at,
        currency as currency_id,
        entity as entity_id,
        postingperiod as accounting_period_id,
        posting = 'T' as is_posting,
        nexus as nexus_id,
        taxregoverride = 'T' as is_nexus_override,
        taxdetailsoverride = 'T' as is_tax_details_override,
        cast(taxpointdate as date) as tax_point_date,
        taxpointdateoverride = 'T' as is_tax_point_date_override,
        intercoadj = 'T' as is_intercompany_adjustment,
        isreversal = 'T' as is_reversal,
        reversal as reversal_transaction_id,
        cast(reversaldate as date) as reversal_date,
        reversaldefer = 'T' as is_reversal_defer

        --The below macro adds the fields defined within your transactions_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
