with base as (

    select 
    from "sap"."main_sap"."stg_sap__t001_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as numeric(28,6)) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    adrnr
    
 , 
    cast(null as TEXT) as 
    
    bapovar
    
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
    
    ebukr
    
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
    
    fstva
    
 , 
    cast(null as TEXT) as 
    
    fstvare
    
 , 
    cast(null as TEXT) as 
    
    impda
    
 , 
    cast(null as TEXT) as 
    
    infmt
    
 , 
    cast(null as TEXT) as 
    
    kkber
    
 , 
    cast(null as TEXT) as 
    
    kokfi
    
 , 
    cast(null as TEXT) as 
    
    kopim
    
 , 
    cast(null as TEXT) as 
    
    ktop2
    
 , 
    cast(null as TEXT) as 
    
    ktopl
    
 , 
    cast(null as TEXT) as 
    
    land1
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
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
    
    offsacct
    
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
    
    pp_pdate
    
 , 
    cast(null as TEXT) as 
    
    pst_per_var
    
 , 
    cast(null as TEXT) as 
    
    rcomp
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 , 
    cast(null as TEXT) as 
    
    stceg
    
 , 
    cast(null as TEXT) as 
    
    surccm
    
 , 
    cast(null as TEXT) as 
    
    txjcd
    
 , 
    cast(null as TEXT) as 
    
    txkrs
    
 , 
    cast(null as TEXT) as 
    
    umkrs
    
 , 
    cast(null as TEXT) as 
    
    waabw
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as TEXT) as 
    
    wfvar
    
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
    
 


    from base
),

final as (

    select
        cast(mandt as TEXT) as mandt,
        cast(bukrs as TEXT) as bukrs,
        dkweg,
        xgjrv,
        xeink,
        fdbuk,
        pp_pdate,
        xprod,
        xskfn,
        xcovr,
        ebukr,
        bukrs_glob,
        xmwsn,
        butxt,
        bapovar,
        xbbko,
        dttdsp,
        dtaxr,
        impda,
        kkber,
        xfmca,
        xfmcb,
        surccm,
        fstvare,
        periv,
        txjcd,
        fmhrdate,
        xbbba,
        ort01,
        rcomp,
        xsplt,
        kopim,
        infmt,
        fm_derive_acc,
        ktopl,
        umkrs,
        xkkbi,
        pst_per_var,
        xvatdate,
        txkrs,
        waers,
        xkdft,
        xcos,
        xbbbf,
        xbbsc,
        xfmco,
        dttaxc,
        mregl,
        mwskv,
        xstdt,
        xnegp,
        spras,
        xvvwa,
        dtprov,
        waabw,
        wt_newwt,
        xcession,
        xslta,
        adrnr,
        xjvaa,
        opvar,
        mwska,
        kokfi,
        ktop2,
        xextb,
        buvar,
        offsacct,
        dtamtc,
        wfvar,
        land1,
        fstva,
        xfdis,
        xbbbe,
        xvalv,
        fikrs,
        xfdsd,
        xfdmm,
        xgsbe,
        stceg,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived
    from fields
)

select * 
from final
