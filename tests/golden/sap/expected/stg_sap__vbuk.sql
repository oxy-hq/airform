with base as (
    select 
    from "sap"."main_sap"."stg_sap__vbuk_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    vbeln
    
 , 
    cast(null as TEXT) as 
    
    rfstk
    
 , 
    cast(null as TEXT) as 
    
    rfgsk
    
 , 
    cast(null as TEXT) as 
    
    bestk
    
 , 
    cast(null as TEXT) as 
    
    lfstk
    
 , 
    cast(null as TEXT) as 
    
    lfgsk
    
 , 
    cast(null as TEXT) as 
    
    wbstk
    
 , 
    cast(null as TEXT) as 
    
    fkstk
    
 , 
    cast(null as TEXT) as 
    
    fksak
    
 , 
    cast(null as TEXT) as 
    
    buchk
    
 , 
    cast(null as TEXT) as 
    
    abstk
    
 , 
    cast(null as TEXT) as 
    
    gbstk
    
 , 
    cast(null as TEXT) as 
    
    kostk
    
 , 
    cast(null as TEXT) as 
    
    lvstk
    
 , 
    cast(null as TEXT) as 
    
    uvals
    
 , 
    cast(null as TEXT) as 
    
    uvvls
    
 , 
    cast(null as TEXT) as 
    
    uvfas
    
 , 
    cast(null as TEXT) as 
    
    uvall
    
 , 
    cast(null as TEXT) as 
    
    uvvlk
    
 , 
    cast(null as TEXT) as 
    
    uvfak
    
 , 
    cast(null as TEXT) as 
    
    uvprs
    
 , 
    cast(null as TEXT) as 
    
    vbtyp
    
 , 
    cast(null as TEXT) as 
    
    vbobj
    
 , 
    cast(null as TEXT) as 
    
    aedat
    
 , 
    cast(null as TEXT) as 
    
    fkivk
    
 , 
    cast(null as TEXT) as 
    
    relik
    
 , 
    cast(null as TEXT) as 
    
    uvk01
    
 , 
    cast(null as TEXT) as 
    
    uvk02
    
 , 
    cast(null as TEXT) as 
    
    uvk03
    
 , 
    cast(null as TEXT) as 
    
    uvk04
    
 , 
    cast(null as TEXT) as 
    
    uvk05
    
 , 
    cast(null as TEXT) as 
    
    uvs01
    
 , 
    cast(null as TEXT) as 
    
    uvs02
    
 , 
    cast(null as TEXT) as 
    
    uvs03
    
 , 
    cast(null as TEXT) as 
    
    uvs04
    
 , 
    cast(null as TEXT) as 
    
    uvs05
    
 , 
    cast(null as TEXT) as 
    
    pkstk
    
 , 
    cast(null as TEXT) as 
    
    cmpsa
    
 , 
    cast(null as TEXT) as 
    
    cmpsb
    
 , 
    cast(null as TEXT) as 
    
    cmpsc
    
 , 
    cast(null as TEXT) as 
    
    cmpsd
    
 , 
    cast(null as TEXT) as 
    
    cmpse
    
 , 
    cast(null as TEXT) as 
    
    cmpsf
    
 , 
    cast(null as TEXT) as 
    
    cmpsg
    
 , 
    cast(null as TEXT) as 
    
    cmpsh
    
 , 
    cast(null as TEXT) as 
    
    cmpsi
    
 , 
    cast(null as TEXT) as 
    
    cmpsj
    
 , 
    cast(null as TEXT) as 
    
    cmpsk
    
 , 
    cast(null as TEXT) as 
    
    cmpsl
    
 , 
    cast(null as TEXT) as 
    
    cmps0
    
 , 
    cast(null as TEXT) as 
    
    cmps1
    
 , 
    cast(null as TEXT) as 
    
    cmps2
    
 , 
    cast(null as TEXT) as 
    
    cmgst
    
 , 
    cast(null as TEXT) as 
    
    trsta
    
 , 
    cast(null as TEXT) as 
    
    koquk
    
 , 
    cast(null as TEXT) as 
    
    costa
    
 , 
    cast(null as TEXT) as 
    
    saprl
    
 , 
    cast(null as TEXT) as 
    
    uvpas
    
 , 
    cast(null as TEXT) as 
    
    uvpis
    
 , 
    cast(null as TEXT) as 
    
    uvwas
    
 , 
    cast(null as TEXT) as 
    
    uvpak
    
 , 
    cast(null as TEXT) as 
    
    uvpik
    
 , 
    cast(null as TEXT) as 
    
    uvwak
    
 , 
    cast(null as TEXT) as 
    
    uvgek
    
 , 
    cast(null as TEXT) as 
    
    cmpsm
    
 , 
    cast(null as TEXT) as 
    
    dcstk
    
 , 
    cast(null as TEXT) as 
    
    vestk
    
 , 
    cast(null as TEXT) as 
    
    vlstk
    
 , 
    cast(null as TEXT) as 
    
    rrsta
    
 , 
    cast(null as TEXT) as 
    
    block
    
 , 
    cast(null as TEXT) as 
    
    fsstk
    
 , 
    cast(null as TEXT) as 
    
    lsstk
    
 , 
    cast(null as TEXT) as 
    
    spstg
    
 , 
    cast(null as TEXT) as 
    
    pdstk
    
 , 
    cast(null as TEXT) as 
    
    fmstk
    
 , 
    cast(null as TEXT) as 
    
    manek
    
 , 
    cast(null as TEXT) as 
    
    spe_tmpid
    
 , 
    cast(null as TEXT) as 
    
    hdall
    
 , 
    cast(null as TEXT) as 
    
    hdals
    
 , 
    cast(null as TEXT) as 
    
    cmps_cm
    
 , 
    cast(null as TEXT) as 
    
    cmps_te
    
 , 
    cast(null as TEXT) as 
    
    vbtyp_ext
    
 , 
    cast(null as TEXT) as 
    
    fsh_ar_stat_hdr
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_rowid
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        aedat,
        cast(vbeln as TEXT) as vbeln,
        rfstk,
        rfgsk,
        bestk,
        lfstk,
        lfgsk,
        wbstk,
        fkstk,
        fksak,
        buchk,
        abstk,
        gbstk,
        kostk,
        lvstk,
        uvals,
        uvvls,
        uvfas,
        uvall,
        uvvlk,
        uvfak,
        uvprs,
        vbtyp,
        vbobj,
        fkivk,
        relik,
        uvk01,
        uvk02,
        uvk03,
        uvk04,
        uvk05,
        uvs01,
        uvs02,
        uvs03,
        uvs04,
        uvs05,
        pkstk,
        cmpsa,
        cmpsb,
        cmpsc,
        cmpsd,
        cmpse,
        cmpsf,
        cmpsg,
        cmpsh,
        cmpsi,
        cmpsj,
        cmpsk,
        cmpsl,
        cmps0,
        cmps1,
        cmps2,
        cmgst,
        trsta,
        koquk,
        costa,
        saprl,
        uvpas,
        uvpis,
        uvwas,
        uvpak,
        uvpik,
        uvwak,
        uvgek,
        cmpsm,
        dcstk,
        vestk,
        vlstk,
        rrsta,
        block,
        fsstk,
        lsstk,
        spstg,
        pdstk,
        fmstk,
        manek,
        spe_tmpid,
        hdall,
        hdals,
        cmps_cm,
        cmps_te,
        vbtyp_ext,
        fsh_ar_stat_hdr,
        hvr_is_deleted,
        hvr_change_time,
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced
    from fields
)

select *
from final
