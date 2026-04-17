with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__transaction_lines_tmp"
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
    cast(null as integer) as 
    
    transaction
    
 , 
    cast(null as integer) as 
    
    linesequencenumber
    
 , 
    cast(null as TEXT) as 
    
    memo
    
 , 
    cast(null as integer) as 
    
    entity
    
 , 
    cast(null as integer) as 
    
    item
    
 , 
    cast(null as integer) as 
    
    class
    
 , 
    cast(null as integer) as 
    
    location
    
 , 
    cast(null as integer) as 
    
    subsidiary
    
 , 
    cast(null as integer) as 
    
    department
    
 , 
    cast(null as TEXT) as 
    
    isclosed
    
 , 
    cast(null as TEXT) as 
    
    isbillable
    
 , 
    cast(null as TEXT) as 
    
    iscogs
    
 , 
    cast(null as TEXT) as 
    
    cleared
    
 , 
    cast(null as TEXT) as 
    
    commitmentfirm
    
 , 
    cast(null as TEXT) as 
    
    mainline
    
 , 
    cast(null as TEXT) as 
    
    taxline
    
 , 
    cast(null as TEXT) as 
    
    eliminate
    
 , 
    cast(null as float) as 
    
    netamount
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as transaction_line_id,
        transaction as transaction_id,
        linesequencenumber as transaction_line_number,
        memo,
        entity as entity_id,
        item as item_id,
        class as class_id,
        location as location_id,
        subsidiary as subsidiary_id,
        department as department_id,
        isclosed = 'T' as is_closed,
        isbillable = 'T' as is_billable,
        iscogs = 'T' as is_cogs,
        cleared = 'T' as is_cleared,
        commitmentfirm = 'T' as is_commitment_firm,
        mainline = 'T' as is_main_line,
        taxline = 'T' as is_tax_line,
        eliminate = 'T' as is_eliminate,
        netamount

        --The below macro adds the fields defined within your transaction_lines_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
