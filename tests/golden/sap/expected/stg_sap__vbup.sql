with base as (
    select 
    from "sap"."main_sap"."stg_sap__vbup_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    posnr
    
 , 
    cast(null as TEXT) as 
    
    vbeln
    
 , 
    cast(null as TEXT) as 
    
    uvpak
    
 , 
    cast(null as TEXT) as 
    
    uvvlk
    
 , 
    cast(null as TEXT) as 
    
    mill_vs_vssta
    
 , 
    cast(null as TEXT) as 
    
    pksta
    
 , 
    cast(null as TEXT) as 
    
    lssta
    
 , 
    cast(null as TEXT) as 
    
    vlstp
    
 , 
    cast(null as TEXT) as 
    
    absta
    
 , 
    cast(null as TEXT) as 
    
    fksta
    
 , 
    cast(null as TEXT) as 
    
    fkivp
    
 , 
    cast(null as TEXT) as 
    
    lfgsa
    
 , 
    cast(null as TEXT) as 
    
    rrsta
    
 , 
    cast(null as TEXT) as 
    
    lfsta
    
 , 
    cast(null as TEXT) as 
    
    fksaa
    
 , 
    cast(null as TEXT) as 
    
    wbsta
    
 , 
    cast(null as TEXT) as 
    
    ltsps
    
 , 
    cast(null as TEXT) as 
    
    costa
    
 , 
    cast(null as TEXT) as 
    
    fssta
    
 , 
    cast(null as TEXT) as 
    
    kosta
    
 , 
    cast(null as TEXT) as 
    
    uvpik
    
 , 
    cast(null as TEXT) as 
    
    uvfak
    
 , 
    cast(null as TEXT) as 
    
    uvall
    
 , 
    cast(null as TEXT) as 
    
    rfgsa
    
 , 
    cast(null as TEXT) as 
    
    uvprs
    
 , 
    cast(null as TEXT) as 
    
    lvsta
    
 , 
    cast(null as TEXT) as 
    
    rfsta
    
 , 
    cast(null as TEXT) as 
    
    cmppj
    
 , 
    cast(null as TEXT) as 
    
    cmppi
    
 , 
    cast(null as TEXT) as 
    
    hdall
    
 , 
    cast(null as TEXT) as 
    
    besta
    
 , 
    cast(null as TEXT) as 
    
    pdsta
    
 , 
    cast(null as TEXT) as 
    
    fsh_ar_stat_itm
    
 , 
    cast(null as TEXT) as 
    
    manek
    
 , 
    cast(null as TEXT) as 
    
    gbsta
    
 , 
    cast(null as TEXT) as 
    
    uvwak
    
 , 
    cast(null as TEXT) as 
    
    dcsta
    
 , 
    cast(null as TEXT) as 
    
    uvp05
    
 , 
    cast(null as TEXT) as 
    
    uvp02
    
 , 
    cast(null as TEXT) as 
    
    uvp04
    
 , 
    cast(null as TEXT) as 
    
    koqua
    
 , 
    cast(null as TEXT) as 
    
    uvp01
    
 , 
    cast(null as TEXT) as 
    
    uvp03
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_sap_archived
    
 


    from base
),

final as (
    select
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived,
        cast(mandt as TEXT) as mandt,
        cast(posnr as TEXT) as posnr,
        cast(vbeln as TEXT) as vbeln,
        uvpak,
        uvvlk,
        mill_vs_vssta,
        pksta,
        lssta,
        vlstp,
        absta,
        fksta,
        fkivp,
        lfgsa,
        rrsta,
        lfsta,
        fksaa,
        wbsta,
        ltsps,
        costa,
        fssta,
        kosta,
        uvpik,
        uvfak,
        uvall,
        rfgsa,
        uvprs,
        lvsta,
        rfsta,
        cmppj,
        cmppi,
        hdall,
        besta,
        pdsta,
        fsh_ar_stat_itm,
        manek,
        gbsta,
        uvwak,
        dcsta,
        uvp05,
        uvp02,
        uvp04,
        koqua,
        uvp01,
        uvp03
    from fields
)

select *
from final
