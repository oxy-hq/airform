with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__prospect_tmp"

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
    
    address_one
    
 , 
    cast(null as TEXT) as 
    
    address_two
    
 , 
    cast(null as TEXT) as 
    
    annual_revenue
    
 , 
    cast(null as integer) as 
    
    campaign_id
    
 , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    comments
    
 , 
    cast(null as TEXT) as 
    
    company
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    crm_account_fid
    
 , 
    cast(null as TEXT) as 
    
    crm_contact_fid
    
 , 
    cast(null as timestamp) as 
    
    crm_last_sync
    
 , 
    cast(null as TEXT) as 
    
    crm_lead_fid
    
 , 
    cast(null as TEXT) as 
    
    crm_owner_fid
    
 , 
    cast(null as TEXT) as 
    
    crm_url
    
 , 
    cast(null as TEXT) as 
    
    department
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    employees
    
 , 
    cast(null as TEXT) as 
    
    fax
    
 , 
    cast(null as TEXT) as 
    
    first_name
    
 , 
    cast(null as TEXT) as 
    
    grade
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    industry
    
 , 
    cast(null as boolean) as 
    
    is_do_not_call
    
 , 
    cast(null as boolean) as 
    
    is_do_not_email
    
 , 
    cast(null as boolean) as 
    
    is_reviewed
    
 , 
    cast(null as boolean) as 
    
    is_starred
    
 , 
    cast(null as TEXT) as 
    
    job_title
    
 , 
    cast(null as timestamp) as 
    
    last_activity_at
    
 , 
    cast(null as TEXT) as 
    
    last_name
    
 , 
    cast(null as TEXT) as 
    
    notes
    
 , 
    cast(null as boolean) as 
    
    opted_out
    
 , 
    cast(null as TEXT) as 
    
    password
    
 , 
    cast(null as TEXT) as 
    
    phone
    
 , 
    cast(null as integer) as 
    
    prospect_account_id
    
 , 
    cast(null as TEXT) as 
    
    recent_interaction
    
 , 
    cast(null as TEXT) as 
    
    salutation
    
 , 
    cast(null as integer) as 
    
    score
    
 , 
    cast(null as TEXT) as 
    
    source
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as TEXT) as 
    
    territory
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as integer) as 
    
    user_id
    
 , 
    cast(null as TEXT) as 
    
    website
    
 , 
    cast(null as TEXT) as 
    
    years_in_business
    
 , 
    cast(null as TEXT) as 
    
    zip
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


        

    from base
    where not coalesce(_fivetran_deleted, false)
),

final as (

    select
        source_relation,
        id as prospect_id,
        _fivetran_deleted,
        _fivetran_synced,
        address_one,
        address_two,
        annual_revenue,
        campaign_id,
        city,
        comments,
        company,
        country,
        created_at as created_timestamp,
        crm_account_fid,
        crm_contact_fid,
        crm_last_sync,
        crm_lead_fid,
        crm_owner_fid,
        crm_url,
        department,
        email,
        employees,
        fax,
        first_name,
        grade,
        industry,
        is_do_not_call,
        is_do_not_email,
        is_reviewed,
        is_starred,
        job_title,
        last_activity_at,
        last_name,
        notes,
        opted_out,
        password,
        phone as phone_number,
        prospect_account_id,
        recent_interaction,
        salutation,
        score,
        source as prospect_source,
        state,
        territory,
        updated_at as updated_timestamp,
        user_id,
        website,
        years_in_business,
        zip
        
        
    from fields
)

select * from final
