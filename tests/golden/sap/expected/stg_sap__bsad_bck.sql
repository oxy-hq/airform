with base as (

    select 
    from "sap"."main_sap"."stg_sap__bsad_bck_tmp"
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
    
    _dataaging
    
 , 
    cast(null as numeric(28,6)) as 
    
    absbt
    
 , 
    cast(null as TEXT) as 
    
    anfae
    
 , 
    cast(null as TEXT) as 
    
    anfbj
    
 , 
    cast(null as TEXT) as 
    
    anfbn
    
 , 
    cast(null as TEXT) as 
    
    anfbu
    
 , 
    cast(null as TEXT) as 
    
    anln1
    
 , 
    cast(null as TEXT) as 
    
    anln2
    
 , 
    cast(null as TEXT) as 
    
    aplzl
    
 , 
    cast(null as TEXT) as 
    
    aufnr
    
 , 
    cast(null as TEXT) as 
    
    aufpl
    
 , 
    cast(null as TEXT) as 
    
    augbl
    
 , 
    cast(null as TEXT) as 
    
    augdt
    
 , 
    cast(null as TEXT) as 
    
    auggj
    
 , 
    cast(null as numeric(28,6)) as 
    
    bdif2
    
 , 
    cast(null as numeric(28,6)) as 
    
    bdif3
    
 , 
    cast(null as numeric(28,6)) as 
    
    bdiff
    
 , 
    cast(null as TEXT) as 
    
    belnr
    
 , 
    cast(null as TEXT) as 
    
    blart
    
 , 
    cast(null as TEXT) as 
    
    bldat
    
 , 
    cast(null as TEXT) as 
    
    bschl
    
 , 
    cast(null as TEXT) as 
    
    bstat
    
 , 
    cast(null as TEXT) as 
    
    btype
    
 , 
    cast(null as TEXT) as 
    
    budat
    
 , 
    cast(null as TEXT) as 
    
    budget_pd
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    bupla
    
 , 
    cast(null as TEXT) as 
    
    buzei
    
 , 
    cast(null as TEXT) as 
    
    buzid
    
 , 
    cast(null as TEXT) as 
    
    bvtyp
    
 , 
    cast(null as TEXT) as 
    
    ccbtc
    
 , 
    cast(null as TEXT) as 
    
    cession_kz
    
 , 
    cast(null as TEXT) as 
    
    cpudt
    
 , 
    cast(null as TEXT) as 
    
    dabrz
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmb21
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmb22
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmb23
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmb31
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmb32
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmb33
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbe2
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbe3
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbt1
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbt2
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbt3
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbtr
    
 , 
    cast(null as TEXT) as 
    
    dtws1
    
 , 
    cast(null as TEXT) as 
    
    dtws2
    
 , 
    cast(null as TEXT) as 
    
    dtws3
    
 , 
    cast(null as TEXT) as 
    
    dtws4
    
 , 
    cast(null as TEXT) as 
    
    egbld
    
 , 
    cast(null as TEXT) as 
    
    eglld
    
 , 
    cast(null as TEXT) as 
    
    egrup
    
 , 
    cast(null as TEXT) as 
    
    empfb
    
 , 
    cast(null as TEXT) as 
    
    eten2
    
 , 
    cast(null as TEXT) as 
    
    filkd
    
 , 
    cast(null as TEXT) as 
    
    fipos
    
 , 
    cast(null as TEXT) as 
    
    fistl
    
 , 
    cast(null as TEXT) as 
    
    fkber
    
 , 
    cast(null as TEXT) as 
    
    fkont
    
 , 
    cast(null as TEXT) as 
    
    geber
    
 , 
    cast(null as TEXT) as 
    
    ghkon
    
 , 
    cast(null as TEXT) as 
    
    gkart
    
 , 
    cast(null as TEXT) as 
    
    gkont
    
 , 
    cast(null as TEXT) as 
    
    gjahr
    
 , 
    cast(null as TEXT) as 
    
    gmvkz
    
 , 
    cast(null as TEXT) as 
    
    grant_nbr
    
 , 
    cast(null as TEXT) as 
    
    gsber
    
 , 
    cast(null as TEXT) as 
    
    hbkid
    
 , 
    cast(null as TEXT) as 
    
    hist_tax_factor
    
 , 
    cast(null as TEXT) as 
    
    hist_tax_factor1
    
 , 
    cast(null as TEXT) as 
    
    hist_tax_factor2
    
 , 
    cast(null as TEXT) as 
    
    hist_tax_factor3
    
 , 
    cast(null as TEXT) as 
    
    hkont
    
 , 
    cast(null as TEXT) as 
    
    hktid
    
 , 
    cast(null as TEXT) as 
    
    imkey
    
 , 
    cast(null as TEXT) as 
    
    infae
    
 , 
    cast(null as TEXT) as 
    
    intreno
    
 , 
    cast(null as TEXT) as 
    
    kblnr
    
 , 
    cast(null as TEXT) as 
    
    kblpos
    
 , 
    cast(null as TEXT) as 
    
    kidno
    
 , 
    cast(null as TEXT) as 
    
    kkber
    
 , 
    cast(null as TEXT) as 
    
    kontt
    
 , 
    cast(null as TEXT) as 
    
    kontl
    
 , 
    cast(null as TEXT) as 
    
    kostl
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    landl
    
 , 
    cast(null as TEXT) as 
    
    lotkz
    
 , 
    cast(null as numeric(28,6)) as 
    
    lwsts
    
 , 
    cast(null as TEXT) as 
    
    lzbkz
    
 , 
    cast(null as TEXT) as 
    
    maber
    
 , 
    cast(null as TEXT) as 
    
    madat
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mansp
    
 , 
    cast(null as TEXT) as 
    
    manst
    
 , 
    cast(null as TEXT) as 
    
    mndid
    
 , 
    cast(null as TEXT) as 
    
    monat
    
 , 
    cast(null as TEXT) as 
    
    mschl
    
 , 
    cast(null as TEXT) as 
    
    mwsk1
    
 , 
    cast(null as TEXT) as 
    
    mwsk2
    
 , 
    cast(null as TEXT) as 
    
    mwsk3
    
 , 
    cast(null as TEXT) as 
    
    mwskz
    
 , 
    cast(null as numeric(28,6)) as 
    
    mwst2
    
 , 
    cast(null as numeric(28,6)) as 
    
    mwst3
    
 , 
    cast(null as numeric(28,6)) as 
    
    mwsts
    
 , 
    cast(null as TEXT) as 
    
    nplnr
    
 , 
    cast(null as TEXT) as 
    
    pays_prov
    
 , 
    cast(null as TEXT) as 
    
    pays_tran
    
 , 
    cast(null as TEXT) as 
    
    posn2
    
 , 
    cast(null as numeric(28,6)) as 
    
    ppdif2
    
 , 
    cast(null as numeric(28,6)) as 
    
    ppdif3
    
 , 
    cast(null as numeric(28,6)) as 
    
    ppdiff
    
 , 
    cast(null as TEXT) as 
    
    pprct
    
 , 
    cast(null as TEXT) as 
    
    prctr
    
 , 
    cast(null as TEXT) as 
    
    projk
    
 , 
    cast(null as TEXT) as 
    
    projn
    
 , 
    cast(null as TEXT) as 
    
    propmano
    
 , 
    cast(null as numeric(28,6)) as 
    
    pswbt
    
 , 
    cast(null as TEXT) as 
    
    pswsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    pyamt
    
 , 
    cast(null as TEXT) as 
    
    pycur
    
 , 
    cast(null as TEXT) as 
    
    qsskz
    
 , 
    cast(null as TEXT) as 
    
    rebzg
    
 , 
    cast(null as TEXT) as 
    
    rebzj
    
 , 
    cast(null as TEXT) as 
    
    rebzt
    
 , 
    cast(null as TEXT) as 
    
    rebzz
    
 , 
    cast(null as TEXT) as 
    
    rfzei
    
 , 
    cast(null as TEXT) as 
    
    rstgr
    
 , 
    cast(null as TEXT) as 
    
    saknr
    
 , 
    cast(null as TEXT) as 
    
    samnr
    
 , 
    cast(null as TEXT) as 
    
    secco
    
 , 
    cast(null as TEXT) as 
    
    sgtxt
    
 , 
    cast(null as TEXT) as 
    
    shkzg
    
 , 
    cast(null as numeric(28,6)) as 
    
    skfbt
    
 , 
    cast(null as numeric(28,6)) as 
    
    sknt2
    
 , 
    cast(null as numeric(28,6)) as 
    
    sknt3
    
 , 
    cast(null as numeric(28,6)) as 
    
    sknto
    
 , 
    cast(null as TEXT) as 
    
    srtype
    
 , 
    cast(null as TEXT) as 
    
    stceg
    
 , 
    cast(null as TEXT) as 
    
    tax_country
    
 , 
    cast(null as TEXT) as 
    
    tax_country1
    
 , 
    cast(null as TEXT) as 
    
    tax_country2
    
 , 
    cast(null as TEXT) as 
    
    tax_country3
    
 , 
    cast(null as TEXT) as 
    
    txdat_from
    
 , 
    cast(null as TEXT) as 
    
    txdat_from1
    
 , 
    cast(null as TEXT) as 
    
    txdat_from2
    
 , 
    cast(null as TEXT) as 
    
    txdat_from3
    
 , 
    cast(null as TEXT) as 
    
    uebgdat
    
 , 
    cast(null as TEXT) as 
    
    umsks
    
 , 
    cast(null as TEXT) as 
    
    umskz
    
 , 
    cast(null as TEXT) as 
    
    uzawe
    
 , 
    cast(null as TEXT) as 
    
    vbel2
    
 , 
    cast(null as TEXT) as 
    
    vbeln
    
 , 
    cast(null as TEXT) as 
    
    vbewa
    
 , 
    cast(null as TEXT) as 
    
    vbund
    
 , 
    cast(null as TEXT) as 
    
    vertn
    
 , 
    cast(null as TEXT) as 
    
    vertt
    
 , 
    cast(null as TEXT) as 
    
    vname
    
 , 
    cast(null as TEXT) as 
    
    vpos2
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as numeric(28,6)) as 
    
    wmwst
    
 , 
    cast(null as numeric(28,6)) as 
    
    wrbt1
    
 , 
    cast(null as numeric(28,6)) as 
    
    wrbt2
    
 , 
    cast(null as numeric(28,6)) as 
    
    wrbt3
    
 , 
    cast(null as numeric(28,6)) as 
    
    wrbtr
    
 , 
    cast(null as numeric(28,6)) as 
    
    wskto
    
 , 
    cast(null as TEXT) as 
    
    wverw
    
 , 
    cast(null as TEXT) as 
    
    xanet
    
 , 
    cast(null as TEXT) as 
    
    xarch
    
 , 
    cast(null as TEXT) as 
    
    xcpdd
    
 , 
    cast(null as TEXT) as 
    
    xegdr
    
 , 
    cast(null as TEXT) as 
    
    xinve
    
 , 
    cast(null as TEXT) as 
    
    xnetb
    
 , 
    cast(null as TEXT) as 
    
    xnegp
    
 , 
    cast(null as TEXT) as 
    
    xnoza
    
 , 
    cast(null as TEXT) as 
    
    xpypr
    
 , 
    cast(null as TEXT) as 
    
    xragl
    
 , 
    cast(null as TEXT) as 
    
    xref1
    
 , 
    cast(null as TEXT) as 
    
    xref2
    
 , 
    cast(null as TEXT) as 
    
    xref3
    
 , 
    cast(null as TEXT) as 
    
    xstov
    
 , 
    cast(null as TEXT) as 
    
    xzahl
    
 , 
    cast(null as numeric(28,6)) as 
    
    zbd1p
    
 , 
    cast(null as numeric(28,6)) as 
    
    zbd1t
    
 , 
    cast(null as numeric(28,6)) as 
    
    zbd2p
    
 , 
    cast(null as numeric(28,6)) as 
    
    zbd2t
    
 , 
    cast(null as numeric(28,6)) as 
    
    zbd3t
    
 , 
    cast(null as TEXT) as 
    
    zbfix
    
 , 
    cast(null as TEXT) as 
    
    zfbdt
    
 , 
    cast(null as TEXT) as 
    
    zinkz
    
 , 
    cast(null as TEXT) as 
    
    zlsch
    
 , 
    cast(null as TEXT) as 
    
    zlspr
    
 , 
    cast(null as TEXT) as 
    
    zterm
    
 , 
    cast(null as TEXT) as 
    
    zumsk
    
 , 
    cast(null as TEXT) as 
    
    zuonr
    
 


    from base
),

final as (

    select
        cast(mandt as TEXT) as mandt,
        cast(bukrs as TEXT) as bukrs,
        cast(kunnr as TEXT) as kunnr,
        umsks,
        umskz,
        augdt,
        cast(augbl as TEXT) as augbl,
        cast(zuonr as TEXT) as zuonr,
        cast(gjahr as TEXT) as gjahr,
        cast(belnr as TEXT) as belnr,
        cast(buzei as TEXT) as buzei,
        budat,
        bldat,
        cpudt,
        cast(waers as TEXT) as waers,
        cast(blart as TEXT) as blart,
        cast(monat as TEXT) as monat,
        cast(bschl as TEXT) as bschl,
        cast(zumsk as TEXT) as zumsk,
        cast(shkzg as TEXT) as shkzg,
        gsber,
        tax_country,
        mwskz,
        txdat_from,
        dmbtr,
        cast(wrbtr as numeric(28,6)) as wrbtr,
        cast(mwsts as numeric(28,6)) as mwsts,
        wmwst,
        lwsts,
        bdiff,
        bdif2,
        cast(sgtxt as TEXT) as sgtxt,
        projn,
        aufnr,
        anln1,
        anln2,
        saknr,
        hkont,
        fkont,
        filkd,
        zfbdt,
        zterm,
        zbd1t,
        zbd2t,
        zbd3t,
        zbd1p,
        zbd2p,
        skfbt,
        cast(sknto as numeric(28,6)) as sknto,
        cast(wskto as numeric(28,6)) as wskto,
        cast(zlsch as TEXT) as zlsch,
        zlspr,
        zbfix,
        hbkid,
        bvtyp,
        rebzg,
        rebzj,
        rebzz,
        samnr,
        anfbn,
        anfbj,
        anfbu,
        anfae,
        mansp,
        mschl,
        madat,
        manst,
        maber,
        xnetb,
        xanet,
        xcpdd,
        xinve,
        xzahl,
        mwsk1,
        txdat_from1,
        tax_country1,
        dmbt1,
        wrbt1,
        hist_tax_factor1,
        mwsk2,
        txdat_from2,
        tax_country2,
        dmbt2,
        wrbt2,
        hist_tax_factor2,
        mwsk3,
        txdat_from3,
        tax_country3,
        dmbt3,
        wrbt3,
        hist_tax_factor3,
        hist_tax_factor,
        bstat,
        vbund,
        vbeln,
        rebzt,
        infae,
        stceg,
        egbld,
        eglld,
        rstgr,
        xnoza,
        vertt,
        vertn,
        vbewa,
        wverw,
        projk,
        fipos,
        nplnr,
        aufpl,
        aplzl,
        xegdr,
        dmbe2,
        dmbe3,
        dmb21,
        dmb22,
        dmb23,
        dmb31,
        dmb32,
        dmb33,
        bdif3,
        xragl,
        uzawe,
        xstov,
        mwst2,
        mwst3,
        sknt2,
        sknt3,
        xref1,
        xref2,
        xarch,
        pswsl,
        pswbt,
        lzbkz,
        landl,
        imkey,
        vbel2,
        vpos2,
        posn2,
        eten2,
        fistl,
        geber,
        dabrz,
        xnegp,
        kostl,
        rfzei,
        kkber,
        empfb,
        prctr,
        xref3,
        qsskz,
        zinkz,
        dtws1,
        dtws2,
        dtws3,
        dtws4,
        xpypr,
        kidno,
        absbt,
        ccbtc,
        pycur,
        pyamt,
        bupla,
        secco,
        cession_kz,
        ppdiff,
        ppdif2,
        ppdif3,
        kblnr,
        kblpos,
        grant_nbr,
        gmvkz,
        srtype,
        lotkz,
        fkber,
        intreno,
        pprct,
        buzid,
        auggj,
        hktid,
        budget_pd,
        pays_prov,
        pays_tran,
        mndid,
        _dataaging,
        kontt,
        kontl,
        uebgdat,
        vname,
        egrup,
        btype,
        propmano,
        gkont,
        gkart,
        ghkon,
        _fivetran_synced
    from fields
)

select *
from final
