with base as (

    select 
    from "sap"."main_sap"."stg_sap__t880_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as numeric(28,6)) as 
    
    _fivetran_rowid
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    cntry
    
 , 
    cast(null as TEXT) as 
    
    curr
    
 , 
    cast(null as TEXT) as 
    
    glsip
    
 , 
    cast(null as TEXT) as 
    
    indpo
    
 , 
    cast(null as TEXT) as 
    
    langu
    
 , 
    cast(null as TEXT) as 
    
    lccomp
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mclnt
    
 , 
    cast(null as TEXT) as 
    
    mcomp
    
 , 
    cast(null as TEXT) as 
    
    modcp
    
 , 
    cast(null as TEXT) as 
    
    name1
    
 , 
    cast(null as TEXT) as 
    
    name2
    
 , 
    cast(null as TEXT) as 
    
    pobox
    
 , 
    cast(null as TEXT) as 
    
    pstlc
    
 , 
    cast(null as TEXT) as 
    
    rcomp
    
 , 
    cast(null as TEXT) as 
    
    resta
    
 , 
    cast(null as TEXT) as 
    
    rform
    
 , 
    cast(null as TEXT) as 
    
    stret
    
 , 
    cast(null as TEXT) as 
    
    strt2
    
 , 
    cast(null as TEXT) as 
    
    zweig
    
 


    from base
),

final as (

    select
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced,
        city,
        cntry,
        curr,
        glsip,
        indpo,
        langu,
        lccomp,
        cast(mandt as TEXT) as mandt,
        mclnt,
        mcomp,
        modcp,
        name1,
        name2,
        pobox,
        pstlc,
        rcomp,
        resta,
        rform,
        stret,
        strt2,
        zweig
    from fields
)

select * 
from final
