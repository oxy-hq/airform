with base as (
    select 
    from "sap"."main_sap"."stg_sap__t134_tmp"
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
    
    aranz
    
 , 
    cast(null as TEXT) as 
    
    ardel
    
 , 
    cast(null as TEXT) as 
    
    begru
    
 , 
    cast(null as TEXT) as 
    
    bsext
    
 , 
    cast(null as TEXT) as 
    
    bsint
    
 , 
    cast(null as TEXT) as 
    
    cchis
    
 , 
    cast(null as TEXT) as 
    
    chneu
    
 , 
    cast(null as TEXT) as 
    
    class
    
 , 
    cast(null as TEXT) as 
    
    ctype
    
 , 
    cast(null as TEXT) as 
    
    ekalr
    
 , 
    cast(null as TEXT) as 
    
    envop
    
 , 
    cast(null as TEXT) as 
    
    flref
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    izust
    
 , 
    cast(null as TEXT) as 
    
    kkref
    
 , 
    cast(null as TEXT) as 
    
    kzgrp
    
 , 
    cast(null as TEXT) as 
    
    kzkfg
    
 , 
    cast(null as TEXT) as 
    
    kzmpn
    
 , 
    cast(null as TEXT) as 
    
    kzpip
    
 , 
    cast(null as TEXT) as 
    
    kzprc
    
 , 
    cast(null as TEXT) as 
    
    kzrac
    
 , 
    cast(null as TEXT) as 
    
    kzvpr
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mbref
    
 , 
    cast(null as TEXT) as 
    
    mstae
    
 , 
    cast(null as TEXT) as 
    
    mtart
    
 , 
    cast(null as TEXT) as 
    
    mtref
    
 , 
    cast(null as TEXT) as 
    
    numke
    
 , 
    cast(null as TEXT) as 
    
    numki
    
 , 
    cast(null as TEXT) as 
    
    prdru
    
 , 
    cast(null as TEXT) as 
    
    pstat
    
 , 
    cast(null as TEXT) as 
    
    vmtpo
    
 , 
    cast(null as TEXT) as 
    
    vnumke
    
 , 
    cast(null as TEXT) as 
    
    vnumki
    
 , 
    cast(null as TEXT) as 
    
    vprsv
    
 , 
    cast(null as TEXT) as 
    
    vtype
    
 , 
    cast(null as TEXT) as 
    
    wmakg
    
 


    from base
),

final as (
    select
        aranz,
        ardel,
        begru,
        bsext,
        bsint,
        cchis,
        chneu,
        class,
        ctype,
        ekalr,
        envop,
        flref,
        hvr_change_time,
        hvr_is_deleted,
        izust,
        kkref,
        kzgrp,
        kzkfg,
        kzmpn,
        kzpip,
        kzprc,
        kzrac,
        kzvpr,
        cast(mandt as TEXT) as mandt,
        mbref,
        mstae,
        mtart,
        mtref,
        numke,
        numki,
        prdru,
        pstat,
        vmtpo,
        vnumke,
        vnumki,
        vprsv,
        vtype,
        wmakg,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_rowid
    from fields
)

select *
from final
