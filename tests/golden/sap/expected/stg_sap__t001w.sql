with base as (
    select 
    from "sap"."main_sap"."stg_sap__t001w_tmp"
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
    
    _fivetran_sap_archived
    
 , 
    cast(null as TEXT) as 
    
    achvm
    
 , 
    cast(null as TEXT) as 
    
    adrnr
    
 , 
    cast(null as TEXT) as 
    
    awsls
    
 , 
    cast(null as TEXT) as 
    
    bapovar
    
 , 
    cast(null as TEXT) as 
    
    bedpl
    
 , 
    cast(null as TEXT) as 
    
    betol
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    bukrs_glob
    
 , 
    cast(null as TEXT) as 
    
    butxt
    
 , 
    cast(null as TEXT) as 
    
    buvar
    
 , 
    cast(null as TEXT) as 
    
    bwkey
    
 , 
    cast(null as TEXT) as 
    
    bzirk
    
 , 
    cast(null as TEXT) as 
    
    bzqhl
    
 , 
    cast(null as TEXT) as 
    
    chazv
    
 , 
    cast(null as TEXT) as 
    
    chazv_old
    
 , 
    cast(null as TEXT) as 
    
    cityc
    
 , 
    cast(null as TEXT) as 
    
    counc
    
 , 
    cast(null as TEXT) as 
    
    dep_store
    
 , 
    cast(null as TEXT) as 
    
    dkweg
    
 , 
    cast(null as TEXT) as 
    
    dtamtc
    
 , 
    cast(null as TEXT) as 
    
    dtaxr
    
 , 
    cast(null as TEXT) as 
    
    dtprov
    
 , 
    cast(null as TEXT) as 
    
    dttaxc
    
 , 
    cast(null as TEXT) as 
    
    dttdsp
    
 , 
    cast(null as TEXT) as 
    
    dvsart
    
 , 
    cast(null as TEXT) as 
    
    ebukr
    
 , 
    cast(null as TEXT) as 
    
    ekorg
    
 , 
    cast(null as TEXT) as 
    
    fabkl
    
 , 
    cast(null as TEXT) as 
    
    fdbuk
    
 , 
    cast(null as TEXT) as 
    
    fikrs
    
 , 
    cast(null as TEXT) as 
    
    fm_derive_acc
    
 , 
    cast(null as TEXT) as 
    
    fmhrdate
    
 , 
    cast(null as TEXT) as 
    
    fprfw
    
 , 
    cast(null as TEXT) as 
    
    fsh_bom_maintenance
    
 , 
    cast(null as TEXT) as 
    
    fsh_mg_arun_req
    
 , 
    cast(null as TEXT) as 
    
    fsh_seaim
    
 , 
    cast(null as TEXT) as 
    
    fstva
    
 , 
    cast(null as TEXT) as 
    
    fstvare
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    impda
    
 , 
    cast(null as TEXT) as 
    
    infmt
    
 , 
    cast(null as TEXT) as 
    
    iwerk
    
 , 
    cast(null as TEXT) as 
    
    j_1bbranch
    
 , 
    cast(null as TEXT) as 
    
    kkber
    
 , 
    cast(null as TEXT) as 
    
    kkowk
    
 , 
    cast(null as TEXT) as 
    
    kokfi
    
 , 
    cast(null as TEXT) as 
    
    kopim
    
 , 
    cast(null as TEXT) as 
    
    kordb
    
 , 
    cast(null as TEXT) as 
    
    ktop2
    
 , 
    cast(null as TEXT) as 
    
    ktopl
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    land1
    
 , 
    cast(null as TEXT) as 
    
    let01
    
 , 
    cast(null as TEXT) as 
    
    let02
    
 , 
    cast(null as TEXT) as 
    
    let03
    
 , 
    cast(null as TEXT) as 
    
    lifnr
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mgvlareval
    
 , 
    cast(null as TEXT) as 
    
    mgvlaupd
    
 , 
    cast(null as TEXT) as 
    
    mgvupd
    
 , 
    cast(null as TEXT) as 
    
    misch
    
 , 
    cast(null as TEXT) as 
    
    mregl
    
 , 
    cast(null as TEXT) as 
    
    mwska
    
 , 
    cast(null as TEXT) as 
    
    mwskv
    
 , 
    cast(null as TEXT) as 
    
    name1
    
 , 
    cast(null as TEXT) as 
    
    name2
    
 , 
    cast(null as TEXT) as 
    
    nodetype
    
 , 
    cast(null as TEXT) as 
    
    nschema
    
 , 
    cast(null as TEXT) as 
    
    offsacct
    
 , 
    cast(null as TEXT) as 
    
    oihcredipi
    
 , 
    cast(null as TEXT) as 
    
    oihvtype
    
 , 
    cast(null as TEXT) as 
    
    oilival
    
 , 
    cast(null as TEXT) as 
    
    opvar
    
 , 
    cast(null as TEXT) as 
    
    ort01
    
 , 
    cast(null as TEXT) as 
    
    periv
    
 , 
    cast(null as TEXT) as 
    
    pfach
    
 , 
    cast(null as TEXT) as 
    
    pkosa
    
 , 
    cast(null as TEXT) as 
    
    pp_pdate
    
 , 
    cast(null as TEXT) as 
    
    pst_per_var
    
 , 
    cast(null as TEXT) as 
    
    pstlz
    
 , 
    cast(null as TEXT) as 
    
    rcomp
    
 , 
    cast(null as TEXT) as 
    
    regio
    
 , 
    cast(null as TEXT) as 
    
    sourcing
    
 , 
    cast(null as TEXT) as 
    
    spart
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 , 
    cast(null as TEXT) as 
    
    stceg
    
 , 
    cast(null as TEXT) as 
    
    storetype
    
 , 
    cast(null as TEXT) as 
    
    stras
    
 , 
    cast(null as TEXT) as 
    
    surccm
    
 , 
    cast(null as TEXT) as 
    
    taxiw
    
 , 
    cast(null as TEXT) as 
    
    txjcd
    
 , 
    cast(null as TEXT) as 
    
    txkrs
    
 , 
    cast(null as TEXT) as 
    
    txnam_ma1
    
 , 
    cast(null as TEXT) as 
    
    txnam_ma2
    
 , 
    cast(null as TEXT) as 
    
    txnam_ma3
    
 , 
    cast(null as TEXT) as 
    
    umkrs
    
 , 
    cast(null as TEXT) as 
    
    vkorg
    
 , 
    cast(null as TEXT) as 
    
    vlfkz
    
 , 
    cast(null as TEXT) as 
    
    vstel
    
 , 
    cast(null as TEXT) as 
    
    vtbfi
    
 , 
    cast(null as TEXT) as 
    
    vtweg
    
 , 
    cast(null as TEXT) as 
    
    waabw
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    wfvar
    
 , 
    cast(null as TEXT) as 
    
    wksop
    
 , 
    cast(null as TEXT) as 
    
    wt_newwt
    
 , 
    cast(null as TEXT) as 
    
    xbbba
    
 , 
    cast(null as TEXT) as 
    
    xbbbe
    
 , 
    cast(null as TEXT) as 
    
    xbbbf
    
 , 
    cast(null as TEXT) as 
    
    xbbko
    
 , 
    cast(null as TEXT) as 
    
    xbbsc
    
 , 
    cast(null as TEXT) as 
    
    xcession
    
 , 
    cast(null as TEXT) as 
    
    xcos
    
 , 
    cast(null as TEXT) as 
    
    xcovr
    
 , 
    cast(null as TEXT) as 
    
    xeink
    
 , 
    cast(null as TEXT) as 
    
    xextb
    
 , 
    cast(null as TEXT) as 
    
    xfdis
    
 , 
    cast(null as TEXT) as 
    
    xfdmm
    
 , 
    cast(null as TEXT) as 
    
    xfdsd
    
 , 
    cast(null as TEXT) as 
    
    xfmca
    
 , 
    cast(null as TEXT) as 
    
    xfmcb
    
 , 
    cast(null as TEXT) as 
    
    xfmco
    
 , 
    cast(null as TEXT) as 
    
    xgjrv
    
 , 
    cast(null as TEXT) as 
    
    xgsbe
    
 , 
    cast(null as TEXT) as 
    
    xjvaa
    
 , 
    cast(null as TEXT) as 
    
    xkdft
    
 , 
    cast(null as TEXT) as 
    
    xkkbi
    
 , 
    cast(null as TEXT) as 
    
    xmwsn
    
 , 
    cast(null as TEXT) as 
    
    xnegp
    
 , 
    cast(null as TEXT) as 
    
    xprod
    
 , 
    cast(null as TEXT) as 
    
    xskfn
    
 , 
    cast(null as TEXT) as 
    
    xslta
    
 , 
    cast(null as TEXT) as 
    
    xsplt
    
 , 
    cast(null as TEXT) as 
    
    xstdt
    
 , 
    cast(null as TEXT) as 
    
    xvalv
    
 , 
    cast(null as TEXT) as 
    
    xvatdate
    
 , 
    cast(null as TEXT) as 
    
    xvvwa
    
 , 
    cast(null as TEXT) as 
    
    zone1
    
 


    from base
),

final as (
    select
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced,
        _fivetran_sap_archived,
        achvm,
        adrnr,
        awsls,
        bapovar,
        bedpl,
        betol,
        cast(bukrs as TEXT) as bukrs,
        bukrs_glob,
        butxt,
        buvar,
        bwkey,
        bzirk,
        bzqhl,
        chazv,
        chazv_old,
        cityc,
        counc,
        dep_store,
        dkweg,
        dtamtc,
        dtaxr,
        dtprov,
        dttaxc,
        dttdsp,
        dvsart,
        ebukr,
        ekorg,
        fabkl,
        fdbuk,
        fikrs,
        fm_derive_acc,
        fmhrdate,
        fprfw,
        fsh_bom_maintenance,
        fsh_mg_arun_req,
        fsh_seaim,
        fstva,
        fstvare,
        hvr_change_time,
        hvr_is_deleted,
        impda,
        infmt,
        iwerk,
        j_1bbranch,
        kkber,
        kkowk,
        kokfi,
        kopim,
        kordb,
        ktop2,
        ktopl,
        cast(kunnr as TEXT) as kunnr,
        land1,
        let01,
        let02,
        let03,
        lifnr,
        cast(mandt as TEXT) as mandt,
        mgvlareval,
        mgvlaupd,
        mgvupd,
        misch,
        mregl,
        mwska,
        mwskv,
        name1,
        name2,
        nodetype,
        nschema,
        offsacct,
        oihcredipi,
        oihvtype,
        oilival,
        opvar,
        ort01,
        periv,
        pfach,
        pkosa,
        pp_pdate,
        pst_per_var,
        pstlz,
        rcomp,
        regio,
        sourcing,
        spart,
        spras,
        stceg,
        storetype,
        stras,
        surccm,
        taxiw,
        txjcd,
        txkrs,
        txnam_ma1,
        txnam_ma2,
        txnam_ma3,
        umkrs,
        vkorg,
        vlfkz,
        vstel,
        vtbfi,
        vtweg,
        waabw,
        waers,
        werks,
        wfvar,
        wksop,
        wt_newwt,
        xbbba,
        xbbbe,
        xbbbf,
        xbbko,
        xbbsc,
        xcession,
        xcos,
        xcovr,
        xeink,
        xextb,
        xfdis,
        xfdmm,
        xfdsd,
        xfmca,
        xfmcb,
        xfmco,
        xgjrv,
        xgsbe,
        xjvaa,
        xkdft,
        xkkbi,
        xmwsn,
        xnegp,
        xprod,
        xskfn,
        xslta,
        xsplt,
        xstdt,
        xvalv,
        xvatdate,
        xvvwa,
        zone1
    from fields
)

select *
from final
