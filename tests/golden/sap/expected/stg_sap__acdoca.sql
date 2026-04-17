with base as (
    select 
    from "sap"."main_sap"."stg_sap__acdoca_tmp"
),

fields as (
    select
        
    cast(null as date) as 
    
    _dataaging
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    accas
    
 , 
    cast(null as TEXT) as 
    
    accasty
    
 , 
    cast(null as TEXT) as 
    
    aworg
    
 , 
    cast(null as TEXT) as 
    
    awref
    
 , 
    cast(null as TEXT) as 
    
    awsys
    
 , 
    cast(null as TEXT) as 
    
    aufnr
    
 , 
    cast(null as TEXT) as 
    
    autyp
    
 , 
    cast(null as TEXT) as 
    
    awtyp
    
 , 
    cast(null as TEXT) as 
    
    beltp
    
 , 
    cast(null as TEXT) as 
    
    belnr
    
 , 
    cast(null as TEXT) as 
    
    co_belnr
    
 , 
    cast(null as TEXT) as 
    
    bschl
    
 , 
    cast(null as numeric(28,6)) as 
    
    bsl
    
 , 
    cast(null as TEXT) as 
    
    bstat
    
 , 
    cast(null as TEXT) as 
    
    bttype
    
 , 
    cast(null as date) as 
    
    budat
    
 , 
    cast(null as TEXT) as 
    
    buzei
    
 , 
    cast(null as TEXT) as 
    
    bwstrat
    
 , 
    cast(null as TEXT) as 
    
    co_beknz
    
 , 
    cast(null as TEXT) as 
    
    co_buzei
    
 , 
    cast(null as TEXT) as 
    
    co_buzei1
    
 , 
    cast(null as TEXT) as 
    
    co_buzei2
    
 , 
    cast(null as TEXT) as 
    
    co_buzei5
    
 , 
    cast(null as TEXT) as 
    
    co_buzei6
    
 , 
    cast(null as TEXT) as 
    
    co_buzei7
    
 , 
    cast(null as TEXT) as 
    
    co_accasty_n1
    
 , 
    cast(null as TEXT) as 
    
    co_accasty_n2
    
 , 
    cast(null as TEXT) as 
    
    co_accasty_n3
    
 , 
    cast(null as numeric(28,6)) as 
    
    co_mefbtr
    
 , 
    cast(null as numeric(28,6)) as 
    
    co_megbtr
    
 , 
    cast(null as TEXT) as 
    
    co_meinh
    
 , 
    cast(null as numeric(28,6)) as 
    
    co_osl
    
 , 
    cast(null as TEXT) as 
    
    co_refbz
    
 , 
    cast(null as TEXT) as 
    
    co_refbz1
    
 , 
    cast(null as TEXT) as 
    
    co_refbz2
    
 , 
    cast(null as TEXT) as 
    
    co_refbz5
    
 , 
    cast(null as TEXT) as 
    
    co_refbz6
    
 , 
    cast(null as TEXT) as 
    
    co_refbz7
    
 , 
    cast(null as TEXT) as 
    
    co_zlenr
    
 , 
    cast(null as numeric(28,6)) as 
    
    csl
    
 , 
    cast(null as TEXT) as 
    
    dabrz
    
 , 
    cast(null as TEXT) as 
    
    docln
    
 , 
    cast(null as TEXT) as 
    
    drcrk
    
 , 
    cast(null as numeric(28,6)) as 
    
    dsl
    
 , 
    cast(null as TEXT) as 
    
    ebeln
    
 , 
    cast(null as TEXT) as 
    
    ebelp
    
 , 
    cast(null as TEXT) as 
    
    egrup
    
 , 
    cast(null as numeric(28,6)) as 
    
    esl
    
 , 
    cast(null as TEXT) as 
    
    erkrs
    
 , 
    cast(null as TEXT) as 
    
    erlkz
    
 , 
    cast(null as numeric(28,6)) as 
    
    fcsl
    
 , 
    cast(null as TEXT) as 
    
    fikrs
    
 , 
    cast(null as numeric(28,6)) as 
    
    fsl
    
 , 
    cast(null as TEXT) as 
    
    gjahr
    
 , 
    cast(null as TEXT) as 
    
    gkoar
    
 , 
    cast(null as TEXT) as 
    
    gkont
    
 , 
    cast(null as numeric(28,6)) as 
    
    gsl
    
 , 
    cast(null as TEXT) as 
    
    hrkft
    
 , 
    cast(null as numeric(28,6)) as 
    
    hsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    kfsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    kfsl2
    
 , 
    cast(null as numeric(28,6)) as 
    
    kfsl3
    
 , 
    cast(null as TEXT) as 
    
    kdauf
    
 , 
    cast(null as TEXT) as 
    
    kdpos
    
 , 
    cast(null as TEXT) as 
    
    kokrs
    
 , 
    cast(null as numeric(28,6)) as 
    
    ksl
    
 , 
    cast(null as TEXT) as 
    
    linetype
    
 , 
    cast(null as TEXT) as 
    
    logsyso
    
 , 
    cast(null as TEXT) as 
    
    logsysp
    
 , 
    cast(null as TEXT) as 
    
    lstar
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as numeric(28,6)) as 
    
    mfsl
    
 , 
    cast(null as TEXT) as 
    
    mig_docln
    
 , 
    cast(null as TEXT) as 
    
    mig_source
    
 , 
    cast(null as numeric(28,6)) as 
    
    msl
    
 , 
    cast(null as TEXT) as 
    
    muvflg
    
 , 
    cast(null as TEXT) as 
    
    objnr
    
 , 
    cast(null as TEXT) as 
    
    objnr_hk
    
 , 
    cast(null as numeric(28,6)) as 
    
    osl
    
 , 
    cast(null as TEXT) as 
    
    paccas
    
 , 
    cast(null as TEXT) as 
    
    paccasty
    
 , 
    cast(null as TEXT) as 
    
    paobjnr
    
 , 
    cast(null as TEXT) as 
    
    parob1
    
 , 
    cast(null as TEXT) as 
    
    parobsrc
    
 , 
    cast(null as TEXT) as 
    
    paufnr
    
 , 
    cast(null as TEXT) as 
    
    pautyp
    
 , 
    cast(null as TEXT) as 
    
    pbukrs
    
 , 
    cast(null as TEXT) as 
    
    pernr
    
 , 
    cast(null as numeric(28,6)) as 
    
    pfsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    pfsl2
    
 , 
    cast(null as numeric(28,6)) as 
    
    pfsl3
    
 , 
    cast(null as TEXT) as 
    
    pkdauf
    
 , 
    cast(null as TEXT) as 
    
    pkdpos
    
 , 
    cast(null as TEXT) as 
    
    plstar
    
 , 
    cast(null as TEXT) as 
    
    poper
    
 , 
    cast(null as TEXT) as 
    
    ppaobjnr
    
 , 
    cast(null as TEXT) as 
    
    pprctr
    
 , 
    cast(null as TEXT) as 
    
    pps_posid
    
 , 
    cast(null as TEXT) as 
    
    pps_pspid
    
 , 
    cast(null as TEXT) as 
    
    prctr
    
 , 
    cast(null as TEXT) as 
    
    prodper
    
 , 
    cast(null as TEXT) as 
    
    ps_posid
    
 , 
    cast(null as TEXT) as 
    
    ps_pspid
    
 , 
    cast(null as TEXT) as 
    
    pscope
    
 , 
    cast(null as numeric(28,6)) as 
    
    psl
    
 , 
    cast(null as numeric(28,6)) as 
    
    psl2
    
 , 
    cast(null as numeric(28,6)) as 
    
    psl3
    
 , 
    cast(null as TEXT) as 
    
    psegment
    
 , 
    cast(null as TEXT) as 
    
    qmnum
    
 , 
    cast(null as numeric(28,6)) as 
    
    quant1
    
 , 
    cast(null as numeric(28,6)) as 
    
    quant2
    
 , 
    cast(null as numeric(28,6)) as 
    
    quant3
    
 , 
    cast(null as TEXT) as 
    
    qunit1
    
 , 
    cast(null as TEXT) as 
    
    qunit2
    
 , 
    cast(null as TEXT) as 
    
    qunit3
    
 , 
    cast(null as TEXT) as 
    
    racct
    
 , 
    cast(null as TEXT) as 
    
    rassc
    
 , 
    cast(null as TEXT) as 
    
    rbest
    
 , 
    cast(null as TEXT) as 
    
    rbukrs
    
 , 
    cast(null as TEXT) as 
    
    rbusa
    
 , 
    cast(null as TEXT) as 
    
    rbudget_pd
    
 , 
    cast(null as TEXT) as 
    
    rcntr
    
 , 
    cast(null as TEXT) as 
    
    rbcur
    
 , 
    cast(null as TEXT) as 
    
    rclnt
    
 , 
    cast(null as TEXT) as 
    
    rccur
    
 , 
    cast(null as TEXT) as 
    
    rdcur
    
 , 
    cast(null as TEXT) as 
    
    re_account
    
 , 
    cast(null as TEXT) as 
    
    re_bukrs
    
 , 
    cast(null as TEXT) as 
    
    recid
    
 , 
    cast(null as TEXT) as 
    
    recur
    
 , 
    cast(null as TEXT) as 
    
    rfarea
    
 , 
    cast(null as TEXT) as 
    
    rfccur
    
 , 
    cast(null as TEXT) as 
    
    rfcur
    
 , 
    cast(null as TEXT) as 
    
    rfund
    
 , 
    cast(null as TEXT) as 
    
    rgcur
    
 , 
    cast(null as TEXT) as 
    
    rgrant_nbr
    
 , 
    cast(null as TEXT) as 
    
    rhcur
    
 , 
    cast(null as TEXT) as 
    
    rkcur
    
 , 
    cast(null as TEXT) as 
    
    rldnr
    
 , 
    cast(null as TEXT) as 
    
    rmvct
    
 , 
    cast(null as TEXT) as 
    
    rocur
    
 , 
    cast(null as TEXT) as 
    
    rrcty
    
 , 
    cast(null as TEXT) as 
    
    rtcur
    
 , 
    cast(null as TEXT) as 
    
    runit
    
 , 
    cast(null as TEXT) as 
    
    rvcur
    
 , 
    cast(null as TEXT) as 
    
    rwcur
    
 , 
    cast(null as TEXT) as 
    
    ryear
    
 , 
    cast(null as TEXT) as 
    
    sbusa
    
 , 
    cast(null as TEXT) as 
    
    sbudget_pd
    
 , 
    cast(null as TEXT) as 
    
    scntr
    
 , 
    cast(null as TEXT) as 
    
    scope
    
 , 
    cast(null as TEXT) as 
    
    segment
    
 , 
    cast(null as TEXT) as 
    
    sfarea
    
 , 
    cast(null as TEXT) as 
    
    sfund
    
 , 
    cast(null as TEXT) as 
    
    sgrant_nbr
    
 , 
    cast(null as TEXT) as 
    
    sgtxt
    
 , 
    cast(null as numeric(28,6)) as timestamp_at , 
    cast(null as numeric(28,6)) as 
    
    tsl
    
 , 
    cast(null as TEXT) as 
    
    usnam
    
 , 
    cast(null as TEXT) as 
    
    uspob
    
 , 
    cast(null as TEXT) as 
    
    vname
    
 , 
    cast(null as TEXT) as 
    
    vrgng
    
 , 
    cast(null as numeric(28,6)) as 
    
    vsl
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as numeric(28,6)) as 
    
    wsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    wsl2
    
 , 
    cast(null as numeric(28,6)) as 
    
    wsl3
    
 , 
    cast(null as TEXT) as 
    
    xsplitmod
    
 , 
    cast(null as TEXT) as 
    
    xpaobjnr_co_rel
    
 , 
    cast(null as TEXT) as 
    
    zekkn
    
 


    from base
),

final as (
    select
        cast(rclnt as TEXT) as rclnt,
        cast(ryear as TEXT) as ryear,
        cast(belnr as TEXT) as belnr,
        cast(co_belnr as TEXT) as co_belnr,
        cast(rbukrs as TEXT) as rbukrs,
        cast(rldnr as TEXT) as rldnr,
        bttype,
        rmvct,
        rtcur,
        cast(runit as TEXT) as runit,
        cast(aufnr as TEXT) as aufnr,
        cast(aworg as TEXT) as aworg,
        cast(awref as TEXT) as awref,
        awtyp,
        autyp,
        rrcty,
        awsys,
        cast(rcntr as TEXT) as rcntr,
        cast(rbcur as TEXT) as rbcur,
        cast(rccur as TEXT) as rccur,
        cast(rdcur as TEXT) as rdcur,
        prctr,
        rbusa,
        cast(kokrs as TEXT) as kokrs,
        segment,
        scntr,
        scope,
        pprctr,
        cast(ppaobjnr as TEXT) as ppaobjnr,
        pps_posid,
        pps_pspid,
        sfarea,
        sbusa,
        rassc,
        rbest,
        psegment,
        qmnum,
        quant1,
        quant2,
        quant3,
        qunit1,
        qunit2,
        qunit3,
        tsl,
        drcrk,
        gjahr,
        budat,
        cast(buzei as TEXT) as buzei,
        bwstrat,
        bschl,
        cast(bstat as TEXT) as bstat,
        linetype,
        xsplitmod,
        usnam,
        _dataaging,
        fikrs,
        sfund,
        sgrant_nbr,
        sgtxt,
        sbudget_pd,
        re_bukrs,
        re_account,
        vname,
        egrup,
        recid,
        cast(recur as TEXT) as recur,
        cast(mig_source as TEXT) as mig_source,
        docln,
        mig_docln,
        cast(rhcur as TEXT) as rhcur,
        cast(rfcur as TEXT) as rfcur,
        cast(rvcur as TEXT) as rvcur,
        fcsl,
        rfccur,
        cast(rkcur as TEXT) as rkcur,
        cast(rocur as TEXT) as rocur,
        cast(objnr as TEXT) as objnr,
        objnr_hk,
        accas,
        cast(accasty as TEXT) as accasty,
        cast(racct as TEXT) as racct,
        hrkft,
        cast(vrgng as TEXT) as vrgng,
        cast(parobsrc as TEXT) as parobsrc,
        cast(parob1 as TEXT) as parob1,
        paccas,
        cast(paccasty as TEXT) as paccasty,
        cast(paobjnr as TEXT) as paobjnr,
        paufnr,
        pautyp,
        pbukrs,
        pernr,
        uspob,
        co_beknz,
        rwcur,
        cast(co_buzei as TEXT) as co_buzei,
        cast(co_buzei1 as TEXT) as co_buzei1,
        cast(co_buzei2 as TEXT) as co_buzei2,
        cast(co_buzei5 as TEXT) as co_buzei5,
        cast(co_buzei6 as TEXT) as co_buzei6,
        cast(co_buzei7 as TEXT) as co_buzei7,
        cast(co_accasty_n1 as TEXT) as co_accasty_n1,
        cast(co_accasty_n2 as TEXT) as co_accasty_n2,
        cast(co_accasty_n3 as TEXT) as co_accasty_n3,
        cast(poper as TEXT) as poper,
        co_meinh,
        wsl,
        wsl2,
        wsl3,
        cast(co_osl as numeric(28,6)) as co_osl,
        co_refbz,
        co_refbz1,
        co_refbz2,
        co_refbz5,
        co_refbz6,
        co_refbz7,
        co_zlenr,
        cast(hsl as numeric(28,6)) as hsl,
        cast(osl as numeric(28,6)) as osl,
        cast(vsl as numeric(28,6)) as vsl,
        cast(bsl as numeric(28,6)) as bsl,
        cast(csl as numeric(28,6)) as csl,
        dabrz,
        cast(dsl as numeric(28,6)) as dsl,
        ebeln,
        ebelp,
        cast(esl as numeric(28,6)) as esl,
        erkrs,
        erlkz,
        cast(fsl as numeric(28,6)) as fsl,
        cast(gsl as numeric(28,6)) as gsl,
        cast(gkoar as TEXT) as gkoar,
        cast(gkont as TEXT) as gkont,
        cast(ksl as numeric(28,6)) as ksl,
        kfsl,
        kfsl2,
        kfsl3,
        kdauf,
        kdpos,
        psl,
        psl2,
        psl3,
        pfsl,
        pfsl2,
        pfsl3,
        pkdauf,
        pkdpos,
        plstar,
        cast(prodper as TEXT) as prodper,
        cast(ps_posid as TEXT) as ps_posid,
        ps_pspid,
        pscope,
        co_megbtr,
        co_mefbtr,
        msl,
        mfsl,
        muvflg,
        beltp,
        rfarea,
        rfund,
        cast(rgcur as TEXT) as rgcur,
        rgrant_nbr,
        rbudget_pd,
        timestamp_at,
        cast(logsyso as TEXT) as logsyso,
        logsysp,
        cast(lstar as TEXT) as lstar,
        matnr,
        werks,
        cast(xpaobjnr_co_rel as TEXT) as xpaobjnr_co_rel,
        zekkn,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
