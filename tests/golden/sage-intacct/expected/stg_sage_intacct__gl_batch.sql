with base as (

    select * 
    from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__gl_batch_tmp"
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
    
    baselocation
    
 , 
    cast(null as integer) as 
    
    baselocation_no
    
 , 
    cast(null as date) as 
    
    batch_date
    
 , 
    cast(null as TEXT) as 
    
    batch_title
    
 , 
    cast(null as integer) as 
    
    batchno
    
 , 
    cast(null as integer) as 
    
    createdby
    
 , 
    cast(null as TEXT) as 
    
    journal
    
 , 
    cast(null as integer) as 
    
    megaentityid
    
 , 
    cast(null as integer) as 
    
    megaentitykey
    
 , 
    cast(null as TEXT) as 
    
    megaentityname
    
 , 
    cast(null as timestamp) as 
    
    modified
    
 , 
    cast(null as integer) as 
    
    modifiedby
    
 , 
    cast(null as TEXT) as 
    
    modifiedbyid
    
 , 
    cast(null as TEXT) as 
    
    module
    
 , 
    cast(null as integer) as 
    
    prbatchkey
    
 , 
    cast(null as TEXT) as 
    
    recordno
    
 , 
    cast(null as TEXT) as 
    
    referenceno
    
 , 
    cast(null as date) as 
    
    reversed
    
 , 
    cast(null as date) as 
    
    reversedfrom
    
 , 
    cast(null as integer) as 
    
    reversedkey
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as TEXT) as 
    
    taximplications
    
 , 
    cast(null as integer) as 
    
    templatekey
    
 , 
    cast(null as TEXT) as 
    
    userinfo_loginid
    
 , 
    cast(null as integer) as 
    
    userkey
    
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
        _fivetran_deleted as is_batch_deleted,
        _fivetran_synced,
        baselocation as base_location,
        baselocation_no as base_location_no,
        batch_date,
        batch_title,
        batchno as batch_no,
        createdby as created_by,
        journal,
        megaentityid as mega_entity_id,
        megaentitykey as mega_entity_key,
        megaentityname as mega_entity_name,
        modified,
        modifiedby as modified_by,
        modifiedbyid as modified_by_id,
        module,
        prbatchkey as pr_batch_key,
        recordno as record_no,
        referenceno as reference_no,
        reversed,
        reversedfrom as reversed_from,
        reversedkey as reversed_key,
        state,
        taximplications as tax_implications,
        templatekey as template_key,
        userinfo_loginid as user_info_login_id,
        userkey as user_key,
        whencreated as when_created,
        whenmodified as when_modified
    from fields
)

select *
from final
