with __dbt__cte__int_coep__acdoca_base as (
with acdoca_base as (

    select *
    from main_sap.stg_sap__acdoca

),

finsc_cmp_versnd_base as (

    select *
    from main_sap.stg_sap__finsc_cmp_versnd

),

tka01_base as (

    select *
    from main_sap.stg_sap__tka01

),

v_coep_acdoca_r1 as (

    select
        a.rclnt as mandt,
        a.kokrs as kokrs,
        a.co_belnr as belnr,
        case
            when v.field_name_buzei = 'CO_BUZEI' then a.co_buzei
            when v.field_name_buzei = 'CO_BUZEI1' then a.co_buzei1
            when v.field_name_buzei = 'CO_BUZEI2' then a.co_buzei2
            when v.field_name_buzei = 'CO_BUZEI5' then a.co_buzei5
            when v.field_name_buzei = 'CO_BUZEI6' then a.co_buzei6
            when v.field_name_buzei = 'CO_BUZEI7' then a.co_buzei7
            else a.co_buzei
        end as buzei,
        a.rldnr as rldnr,
        v.versn as versn,
        a.budat,
        a.poper as perio,
        a.rwcur as twaer,
        case v.field_name_wtgbtr_add
            when 'WSL' then a.wsl
            when 'WSL2' then a.wsl2
            when 'WSL3' then a.wsl3
            else cast(0 as NUMERIC)
        end as wtgbtr_add,
        case v.field_name_wtgbtr_subtract
            when 'WSL' then a.wsl
            when 'WSL2' then a.wsl2
            when 'WSL3' then a.wsl3
            else cast(0 as NUMERIC)
        end as wtgbtr_subtract,
        case
            when (a.rocur is null or cast(a.rocur as VARCHAR) = '' or cast(t.xwbuk as VARCHAR) = 'X') then a.rhcur
            else a.rocur
        end as owaer,
        case
            when cast(v.set_to_zero as VARCHAR) = 'X' then 0
            when v.field_name_wogbtr_add = 'CO_OSL' then a.co_osl
            when v.field_name_wogbtr_add = 'HSL' then a.hsl
            when v.field_name_wogbtr_add = 'OSL' then a.osl
            when v.field_name_wogbtr_add = 'VSL' then a.vsl
            when v.field_name_wogbtr_add = 'BSL' then a.bsl
            when v.field_name_wogbtr_add = 'CSL' then a.csl
            when v.field_name_wogbtr_add = 'DSL' then a.dsl
            when v.field_name_wogbtr_add = 'ESL' then a.esl
            when v.field_name_wogbtr_add = 'FSL' then a.fsl
            when v.field_name_wogbtr_add = 'GSL' then a.gsl
            when v.field_name_wogbtr_add = 'KSL' then a.ksl
            else cast(0 as NUMERIC)
        end as wogbtr_add,
        case v.field_name_wogbtr_subtract
            when 'HSL' then a.hsl
            when 'OSL' then a.osl
            when 'CO_OSL' then a.co_osl
            when 'VSL' then a.vsl
            when 'BSL' then a.bsl
            when 'CSL' then a.csl
            when 'DSL' then a.dsl
            when 'ESL' then a.esl
            when 'FSL' then a.fsl
            when 'GSL' then a.gsl
            when 'KSL' then a.ksl
            else cast(0 as NUMERIC)
        end as wogbtr_subtract,
        case
            when cast(v.set_to_zero as VARCHAR) = 'X' then a.rkcur
            when v.field_name_wkgbtr_add = 'KSL' then a.rkcur
            when v.field_name_wkgbtr_add = 'OSL' then a.rocur
            when v.field_name_wkgbtr_add = 'VSL' then a.rvcur
            when v.field_name_wkgbtr_add = 'BSL' then a.rbcur
            when v.field_name_wkgbtr_add = 'CSL' then a.rccur
            when v.field_name_wkgbtr_add = 'DSL' then a.rdcur
            when v.field_name_wkgbtr_add = 'ESL' then a.recur
            when v.field_name_wkgbtr_add = 'FSL' then a.rfcur
            when v.field_name_wkgbtr_add = 'GSL' then a.rgcur
            when v.field_name_wkgbtr_add = 'HSL' then a.rhcur
            when v.field_name_wkgbtr_subtract = 'KSL' then a.rkcur
            when v.field_name_wkgbtr_subtract = 'OSL' then a.rocur
            when v.field_name_wkgbtr_subtract = 'VSL' then a.rvcur
            when v.field_name_wkgbtr_subtract = 'BSL' then a.rbcur
            when v.field_name_wkgbtr_subtract = 'CSL' then a.rccur
            when v.field_name_wkgbtr_subtract = 'DSL' then a.rdcur
            when v.field_name_wkgbtr_subtract = 'ESL' then a.recur
            when v.field_name_wkgbtr_subtract = 'FSL' then a.rfcur
            when v.field_name_wkgbtr_subtract = 'GSL' then a.rgcur
            when v.field_name_wkgbtr_subtract = 'HSL' then a.rhcur
            else cast('' as VARCHAR)
        end as kwaer,
        case v.field_name_wkgbtr_add
            when 'KSL' then a.ksl
            when 'OSL' then a.osl
            when 'VSL' then a.vsl
            when 'BSL' then a.bsl
            when 'CSL' then a.csl
            when 'DSL' then a.dsl
            when 'ESL' then a.esl
            when 'FSL' then a.fsl
            when 'GSL' then a.gsl
            when 'HSL' then a.hsl
            else cast(0 as NUMERIC)
        end as wkgbtr_add,
        case v.field_name_wkgbtr_subtract
            when 'KSL' then a.ksl
            when 'OSL' then a.osl
            when 'VSL' then a.vsl
            when 'BSL' then a.bsl
            when 'CSL' then a.csl
            when 'DSL' then a.dsl
            when 'ESL' then a.esl
            when 'FSL' then a.fsl
            when 'GSL' then a.gsl
            when 'HSL' then a.hsl
            else cast(0 as NUMERIC)
        end as wkgbtr_subtract,
        case v.field_name_wkfbtr_add
            when 'KFSL' then a.kfsl
            when 'KFSL2' then a.kfsl2
            when 'KFSL3' then a.kfsl3
            else cast(0 as NUMERIC)
        end as wkfbtr_add,
        case v.field_name_wkfbtr_subtract
            when 'KFSL' then a.kfsl
            when 'KFSL2' then a.kfsl2
            when 'KFSL3' then a.kfsl3
            else cast(0 as NUMERIC)
        end as wkfbtr_subtract,
        case v.field_name_pagbtr_add
            when 'PSL' then a.psl
            when 'PSL2' then a.psl2
            when 'PSL3' then a.psl3
            else cast(0 as NUMERIC)
        end as pagbtr_add,
        case v.field_name_pagbtr_subtract
            when 'PSL' then a.psl
            when 'PSL2' then a.psl2
            when 'PSL3' then a.psl3
            else cast(0 as NUMERIC)
        end as pagbtr_subtract,
        case v.field_name_pafbtr_add
            when 'PFSL' then a.pfsl
            when 'PFSL2' then a.pfsl2
            when 'PFSL3' then a.pfsl3
            else cast(0 as NUMERIC)
        end as pafbtr_add,
        case v.field_name_pafbtr_subtract
            when 'PFSL' then a.pfsl
            when 'PFSL2' then a.pfsl2
            when 'PFSL3' then a.pfsl3
            else cast(0 as NUMERIC)
        end as pafbtr_subtract,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.co_megbtr
            else cast(0 as NUMERIC)
        end as megbtr,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.co_mefbtr
            else cast(0 as NUMERIC)
        end as mefbtr,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.msl
            else cast(0 as NUMERIC)
        end as mbgbtr,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.mfsl
            else cast(0 as NUMERIC)
        end as mbfbtr,
        cast('00' as VARCHAR) as lednr,
        a.objnr,
        a.ryear as gjahr,
        case
            when (a.accasty is null or cast(a.accasty as VARCHAR) = '') then cast('11' as VARCHAR)
            else cast('04' as VARCHAR)
        end as wrttp,
        a.racct as kstar,
        a.hrkft,
        a.vrgng,
        case
            when a.parobsrc = '1' then a.parob1
            else (
                case
                    when a.parobsrc = '2' then a.paccasty
                    else cast('' as VARCHAR)
                end
            )
        end as parob,
        a.parob1,
        a.uspob,
        a.rassc as vbund,
        a.sbusa as pargb,
        a.co_beknz as beknz,
        a.co_meinh as meinh,
        case
            when (a.runit is null or cast(a.runit as VARCHAR) = '') then cast('' as VARCHAR)
            else a.runit
        end as meinb,
        a.muvflg,
        a.sgtxt,
        case
            when v.field_name_refbz = 'CO_REFBZ' then a.co_refbz
            when v.field_name_refbz = 'CO_REFBZ1' then a.co_refbz1
            when v.field_name_refbz = 'CO_REFBZ2' then a.co_refbz2
            when v.field_name_refbz = 'CO_REFBZ5' then a.co_refbz5
            when v.field_name_refbz = 'CO_REFBZ6' then a.co_refbz6
            when v.field_name_refbz = 'CO_REFBZ7' then a.co_refbz7
            else a.co_refbz
        end as refbz,
        a.co_zlenr as zlenr,
        a.co_buzei as bw_refbz,
        case
            when (a.vrgng in ('COIN', 'COIE', 'KZRI', 'INV1', 'INV2', 'INV3', 'INV4', 'INV5', 'INV6', 'RKU3')) then a.gkont
            else cast('' as VARCHAR)
        end as gkont,
        case
            when (a.vrgng in ('COIN', 'COIE', 'KZRI', 'INV1', 'INV2', 'INV3', 'INV4', 'INV5', 'INV6', 'RKU3')) then a.gkoar
            else cast('' as VARCHAR)
        end as gkoar,
        a.werks,
        a.matnr,
        a.rbest,
        a.ebeln,
        a.ebelp,
        a.zekkn,
        a.erlkz,
        a.pernr,
        case
            when a.xpaobjnr_co_rel = 'X' then a.paobjnr
            else cast('0000000000' as VARCHAR)
        end as paobjnr,
        a.beltp,
        a.rbukrs as bukrs,
        a.rbusa as gsber,
        a.rfarea as fkber,
        a.scope,
        a.logsyso,
        cast('' as VARCHAR) as pkstar,
        a.pbukrs,
        a.sfarea as pfkber,
        a.pscope,
        a.logsysp,
        a.dabrz,
        a.bwstrat,
        a.objnr_hk,
        a.timestamp_at,
        a.qmnum,
        a.rfund as geber,
        a.sfund as pgeber,
        a.rgrant_nbr as grant_nbr,
        a.sgrant_nbr as pgrant_nbr,
        case
            when (a.vrgng in ('COIN', 'COIE', 'KZRI', 'INV1', 'INV2', 'INV3', 'INV4', 'INV5', 'INV6')) then a.buzei
            else cast('000' as VARCHAR)
        end as refbz_fi,
        a.segment,
        a.psegment,
        cast('0000000000' as VARCHAR) as posnr,
        a.prctr,
        a.pprctr as pprct,
        a.rbudget_pd as budget_pd,
        a.sbudget_pd as pbudget_pd,
        concat(rtrim(substring(a.prodper, 1, 4)), rtrim(substring(a.prodper, 5, 2))) as prodper,
        a.awtyp,
        replace(rtrim(replace(rtrim(concat(rtrim(rpad(a.awref, 10, '€')), rtrim(a.aworg))), rtrim('€'), rtrim('€'))), rtrim('€'), rtrim('')) as awkey,
        a.awsys,
        a.accas,
        a.accasty,
        a.rcntr as kostl,
        a.lstar,
        a.aufnr,
        a.autyp,
        a.ps_posid as pspnr,
        a.ps_pspid as pspid,
        a.kdauf as vbeln,
        a.kdpos as vbposnr,
        case
            when a.accasty = 'EO' then rtrim(substring(a.objnr, 7, 10))
            else (
                case
                    when (not (a.paobjnr = '0000000000') and a.xpaobjnr_co_rel = 'X') then a.paobjnr
                    else cast('0000000000' as VARCHAR)
                end
            )
        end as ce4key,
        a.erkrs as erkrs,
        a.paccas,
        a.paccasty,
        a.scntr as pkostl,
        a.plstar,
        a.paufnr,
        a.pautyp,
        a.pps_posid as ppspnr,
        a.pps_pspid as ppspid,
        a.pkdauf as pvbeln,
        a.pkdpos as pvbposnr,
        case
            when a.paccasty = 'EO' then rtrim(substring(a.parob1, 7, 10))
            else (
                case
                    when (not (a.paobjnr = '0000000000') and a.xpaobjnr_co_rel = 'X') then a.ppaobjnr
                    else cast('0000000000' as VARCHAR)
                end
            )
        end as pce4key,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.quant1
            else cast(0 as NUMERIC)
        end as quant1,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.quant2
            else cast(0 as NUMERIC)
        end as quant2,
        case
            when (cast(v.versn as VARCHAR) = '000' and not (cast(v.set_to_zero as VARCHAR) = 'X')) then a.quant3
            else cast(0 as NUMERIC)
        end as quant3,
        a.qunit1,
        a.qunit2,
        a.qunit3,
        a.co_accasty_n1,
        a.co_accasty_n2,
        a.co_accasty_n3

    from acdoca_base as a
    inner join finsc_cmp_versnd_base as v
        on cast(v.mandt as VARCHAR) = cast(a.rclnt as VARCHAR)
        and cast(v.bukrs as VARCHAR) = cast(a.rbukrs as VARCHAR)
        and cast(v.rldnr as VARCHAR) = cast(a.rldnr as VARCHAR)
        and cast(a.rclnt as VARCHAR) = cast(v.mandt as VARCHAR)
    inner join tka01_base t
        on cast(t.mandt as VARCHAR) = cast(a.rclnt as VARCHAR)
        and cast(t.kokrs as VARCHAR) = cast(a.kokrs as VARCHAR)
        and cast(a.rclnt as VARCHAR) = cast(t.mandt as VARCHAR)
    where not (cast(a.co_buzei as VARCHAR) = '000')
        and not (cast(a.accasty as VARCHAR) = '')
        and not (cast(a.objnr as VARCHAR) = '')

)

select * from v_coep_acdoca_r1
),
__dbt__cte__int_coep__acdoca_calculated as (
with base as (

    select *
    from __dbt__cte__int_coep__acdoca_base

)

select
    mandt,
    kokrs,
    belnr,
    buzei,
    rldnr,
    versn,
    budat,
    perio,
    cast((wtgbtr_add - wtgbtr_subtract) as NUMERIC) as wtgbtr,
    cast((wogbtr_add - wogbtr_subtract) as NUMERIC) as wogbtr,
    cast((wkgbtr_add - wkgbtr_subtract) as NUMERIC) as wkgbtr,
    cast((wkfbtr_add - wkfbtr_subtract) as NUMERIC) as wkfbtr,
    cast((pagbtr_add - pagbtr_subtract) as NUMERIC) as pagbtr,
    cast((pafbtr_add - pafbtr_subtract) as NUMERIC) as pafbtr,
    megbtr,
    mefbtr,
    mbgbtr,
    mbfbtr,
    lednr,
    objnr,
    gjahr,
    wrttp,
    kstar,
    hrkft,
    vrgng,
    parob,
    parob1,
    uspob,
    vbund,
    pargb,
    beknz,
    twaer,
    owaer,
    meinh,
    meinb,
    muvflg,
    sgtxt,
    refbz,
    zlenr,
    bw_refbz,
    gkont,
    gkoar,
    werks,
    matnr,
    rbest,
    ebeln,
    ebelp,
    zekkn,
    erlkz,
    pernr,
    paobjnr,
    beltp,
    bukrs,
    gsber,
    fkber,
    scope,
    logsyso,
    pkstar,
    pbukrs,
    pfkber,
    pscope,
    logsysp,
    dabrz,
    bwstrat,
    objnr_hk,
    timestamp_at,
    qmnum,
    geber,
    pgeber,
    grant_nbr,
    pgrant_nbr,
    refbz_fi,
    segment,
    psegment,
    posnr,
    prctr,
    pprct,
    budget_pd,
    pbudget_pd,
    prodper,
    awtyp,
    awkey,
    awsys,
    kwaer,
    accas,
    accasty,
    kostl,
    lstar,
    aufnr,
    autyp,
    pspnr,
    pspid,
    vbeln,
    vbposnr,
    ce4key,
    erkrs,
    paccas,
    paccasty,
    pkostl,
    plstar,
    paufnr,
    pautyp,
    ppspnr,
    ppspid,
    pvbeln,
    pvbposnr,
    pce4key,
    quant1,
    quant2,
    quant3,
    qunit1,
    qunit2,
    qunit3,
    co_accasty_n1,
    co_accasty_n2,
    co_accasty_n3

from base
where not (cast(buzei as VARCHAR) = '000')
),
__dbt__cte__int_coep__acdoca_aggregated as (
with base as (

    select *
    from __dbt__cte__int_coep__acdoca_calculated

)

select
    mandt,
    kokrs,
    belnr,
    buzei,
    versn,
    budat,
    perio,
    lednr,
    objnr,
    gjahr,
    wrttp,
    kstar,
    hrkft,
    vrgng,
    parob,
    parob1,
    uspob,
    vbund,
    pargb,
    beknz,
    twaer,
    owaer,
    meinh,
    meinb,
    bukrs,
    pkstar,
    pbukrs,
    awtyp,
    awkey,
    awsys,
    kwaer,
    accas,
    accasty,
    paccas,
    paccasty,
    qunit1,
    qunit2,
    qunit3,
    co_accasty_n1,
    co_accasty_n2,
    co_accasty_n3,
    sum(wtgbtr) as wtgbtr,
    sum(wogbtr) as wogbtr,
    sum(wkgbtr) as wkgbtr,
    sum(wkfbtr) as wkfbtr,
    sum(pagbtr) as pagbtr,
    sum(pafbtr) as pafbtr,
    sum(megbtr) as megbtr,
    sum(mefbtr) as mefbtr,
    sum(mbgbtr) as mbgbtr,
    sum(mbfbtr) as mbfbtr,
    max(muvflg) as muvflg,
    max(sgtxt) as sgtxt,
    max(refbz) as refbz,
    max(zlenr) as zlenr,
    max(bw_refbz) as bw_refbz,
    max(gkont) as gkont,
    max(gkoar) as gkoar,
    max(werks) as werks,
    max(matnr) as matnr,
    max(rbest) as rbest,
    max(ebeln) as ebeln,
    max(ebelp) as ebelp,
    max(zekkn) as zekkn,
    max(erlkz) as erlkz,
    max(pernr) as pernr,
    max(paobjnr) as paobjnr,
    max(beltp) as beltp,
    max(gsber) as gsber,
    max(fkber) as fkber,
    max(scope) as scope,
    max(logsyso) as logsyso,
    max(pfkber) as pfkber,
    max(pscope) as pscope,
    max(logsysp) as logsysp,
    max(dabrz) as dabrz,
    max(bwstrat) as bwstrat,
    max(objnr_hk) as objnr_hk,
    max(timestamp_at) as timestamp_at,
    max(qmnum) as qmnum,
    max(geber) as geber,
    max(pgeber) as pgeber,
    max(grant_nbr) as grant_nbr,
    max(pgrant_nbr) as pgrant_nbr,
    max(refbz_fi) as refbz_fi,
    max(segment) as segment,
    max(psegment) as psegment,
    max(posnr) as posnr,
    max(prctr) as prctr,
    max(pprct) as pprct,
    max(budget_pd) as budget_pd,
    max(pbudget_pd) as pbudget_pd,
    max(prodper) as prodper,
    max(kostl) as kostl,
    max(lstar) as lstar,
    max(aufnr) as aufnr,
    max(autyp) as autyp,
    max(pspnr) as pspnr,
    max(pspid) as pspid,
    max(vbeln) as vbeln,
    max(vbposnr) as vbposnr,
    max(ce4key) as ce4key,
    max(erkrs) as erkrs,
    max(pkostl) as pkostl,
    max(plstar) as plstar,
    max(paufnr) as paufnr,
    max(pautyp) as pautyp,
    max(ppspnr) as ppspnr,
    max(ppspid) as ppspid,
    max(pvbeln) as pvbeln,
    max(pvbposnr) as pvbposnr,
    max(pce4key) as pce4key,
    sum(quant1) as quant1,
    sum(quant2) as quant2,
    sum(quant3) as quant3

from base
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41
),
__dbt__cte__int_coep__acdoca_final as (
with base as (

    select *
    from __dbt__cte__int_coep__acdoca_aggregated

)

select
    mandt,
    kokrs,
    belnr,
    buzei,
    versn,
    budat,
    perio,
    wtgbtr,
    wogbtr,
    wkgbtr,
    wkfbtr,
    pagbtr,
    pafbtr,
    megbtr,
    mefbtr,
    mbgbtr,
    mbfbtr,
    lednr,
    objnr,
    gjahr,
    wrttp,
    kstar,
    hrkft,
    vrgng,
    parob,
    parob1,
    uspob,
    vbund,
    pargb,
    beknz,
    twaer,
    owaer,
    meinh,
    meinb,
    muvflg,
    sgtxt,
    refbz,
    zlenr,
    bw_refbz,
    gkont,
    gkoar,
    werks,
    matnr,
    rbest,
    ebeln,
    ebelp,
    zekkn,
    erlkz,
    pernr,
    paobjnr,
    beltp,
    bukrs,
    gsber,
    fkber,
    scope,
    logsyso,
    pkstar,
    pbukrs,
    pfkber,
    pscope,
    logsysp,
    dabrz,
    bwstrat,
    objnr_hk,
    timestamp_at as timestmp,
    qmnum,
    geber,
    pgeber,
    grant_nbr,
    pgrant_nbr,
    refbz_fi,
    segment,
    psegment,
    posnr,
    prctr,
    pprct,
    budget_pd,
    pbudget_pd,
    prodper,
    awtyp,
    awkey,
    awsys,
    kwaer,
    accas,
    accasty,
    kostl,
    lstar,
    aufnr,
    autyp,
    pspnr,
    pspid,
    vbeln,
    vbposnr,
    ce4key,
    erkrs,
    paccas,
    paccasty,
    pkostl,
    plstar,
    paufnr,
    pautyp,
    ppspnr,
    ppspid,
    pvbeln,
    pvbposnr,
    pce4key,
    quant1,
    quant2,
    quant3,
    qunit1,
    qunit2,
    qunit3,
    co_accasty_n1 as objnr_n1,
    co_accasty_n2 as objnr_n2,
    co_accasty_n3 as objnr_n3

from base
where (cast(versn as VARCHAR) = '000'
    or not (wogbtr = 0)
    or not (wkgbtr = 0)
    or not (wkfbtr = 0)
    or not (wtgbtr = 0)
    or not (pagbtr = 0)
    or not (pafbtr = 0)
    or not (megbtr = 0)
    or not (mefbtr = 0)
    or not (mbgbtr = 0)
    or not (mbfbtr = 0)
    or not (quant1 = 0)
    or not (quant2 = 0)
    or not (quant3 = 0))
),
__dbt__cte__int_coep__original as (
with coep_base as (

    select *
    from main_sap.stg_sap__coep

),

prps_base as (

    select *
    from main_sap.stg_sap__prps

),

acdoca_final as (

    select *
    from __dbt__cte__int_coep__acdoca_final

)

select
    c.mandt as mandt,
    c.kokrs,
    c.belnr,
    c.buzei,
    c.perio,
    c.wtgbtr,
    c.wogbtr,
    c.wkgbtr,
    c.wkfbtr,
    c.pagbtr,
    c.pafbtr,
    c.megbtr,
    c.mefbtr,
    c.mbgbtr,
    c.mbfbtr,
    c.lednr,
    c.objnr as objnr,
    c.gjahr,
    c.wrttp,
    c.versn,
    c.kstar,
    c.hrkft,
    c.vrgng,
    c.parob,
    c.parob1,
    c.uspob,
    c.vbund,
    c.pargb,
    c.beknz,
    c.twaer,
    c.owaer,
    c.meinh,
    c.meinb,
    c.muvflg as mvflg,
    c.sgtxt,
    c.refbz,
    c.zlenr,
    c.bw_refbz,
    c.gkont,
    c.gkoar,
    c.werks as werks,
    c.matnr as matnr,
    c.rbest,
    c.ebeln,
    c.ebelp,
    c.zekkn,
    c.erlkz,
    c.pernr,
    cast('00' as VARCHAR) as btrkl,
    c.paobjnr,
    c.beltp,
    c.bukrs,
    c.gsber,
    c.fkber,
    c.scope as scope,
    c.logsyso,
    c.pkstar,
    c.pbukrs,
    c.pfkber,
    c.pscope,
    c.logsysp,
    c.dabrz,
    c.bwstrat,
    c.objnr_hk,
    c.timestmp,
    c.qmnum,
    c.geber,
    c.pgeber,
    c.grant_nbr,
    c.pgrant_nbr,
    c.refbz_fi,
    c.segment,
    c.psegment,
    c.posnr,
    c.prctr as prctr,
    c.pprct,
    c.budget_pd,
    c.pbudget_pd,
    c.prodper,
    c.awtyp,
    c.awkey,
    c.awsys,
    c.kwaer,
    c.kostl as kostl,
    c.lstar,
    c.aufnr,
    c.autyp,
    c.pspnr as pspnr,
    c.pspid,
    c.vbeln,
    c.vbposnr,
    c.ce4key,
    case
        when (c.accasty is null or c.accasty = '') then rtrim(substring(c.objnr, 1, 2))
        else c.accasty
    end as accasty,
    c.accas,
    case
        when not (cast(c.objnr_n1 as VARCHAR) = '') then (
            case
                when c.objnr_n1 like 'KS%' then replace(rtrim(replace(rtrim(concat(rtrim(concat('KS', rtrim(substring(concat(rtrim(c.kokrs), '€€€€'), 1, 4)))), rtrim(c.kostl))), rtrim('€'), rtrim(' €'))), rtrim('€'), rtrim(''))
                when c.objnr_n1 like 'KL%' then replace(rtrim(replace(rtrim(concat(rtrim(concat(rtrim(concat('KL', rtrim(substring(concat(rtrim(c.kokrs), '€€€€'), 1, 4)))), rtrim(substring(concat(rtrim(c.kostl), '€€€€€€€€€€'), 1, 10)))), rtrim(c.lstar))), rtrim('€'), rtrim(' €'))), rtrim('€'), rtrim(''))
                when c.objnr_n1 like 'OR%' then concat('OR', rtrim(c.aufnr))
                when c.objnr_n1 like 'PR%' then coalesce(p.objnr, cast('' as VARCHAR))
                else cast('' as VARCHAR)
            end
        )
        else cast('' as VARCHAR)
    end as objnr_n1,
    case
        when not (cast(c.objnr_n2 as VARCHAR) = '') then (
            case
                when c.objnr_n2 like 'KS%' then replace(rtrim(replace(rtrim(concat(rtrim(concat('KS', rtrim(substring(concat(rtrim(c.kokrs), '€€€€'), 1, 4)))), rtrim(c.kostl))), rtrim('€'), rtrim(' €'))), rtrim('€'), rtrim(''))
                when c.objnr_n2 like 'KL%' then replace(rtrim(replace(rtrim(concat(rtrim(concat(rtrim(concat('KL', rtrim(substring(concat(rtrim(c.kokrs), '€€€€'), 1, 4)))), rtrim(substring(concat(rtrim(c.kostl), '€€€€€€€€€€'), 1, 10)))), rtrim(c.lstar))), rtrim('€'), rtrim(' €'))), rtrim('€'), rtrim(''))
                when c.objnr_n2 like 'OR%' then concat('OR', rtrim(c.aufnr))
                when c.objnr_n2 like 'PR%' then coalesce(p.objnr, cast('' as VARCHAR))
                else cast('' as VARCHAR)
            end
        )
        else cast('' as VARCHAR)
    end as objnr_n2,
    case
        when not (cast(c.objnr_n3 as VARCHAR) = '') then (
            case
                when c.objnr_n3 like 'KS%' then replace(rtrim(replace(rtrim(concat(rtrim(concat('KS', rtrim(substring(concat(rtrim(c.kokrs), '€€€€'), 1, 4)))), rtrim(c.kostl))), rtrim('€'), rtrim(' €'))), rtrim('€'), rtrim(''))
                when c.objnr_n3 like 'KL%' then replace(rtrim(replace(rtrim(concat(rtrim(concat(rtrim(concat('KL', rtrim(substring(concat(rtrim(c.kokrs), '€€€€'), 1, 4)))), rtrim(substring(concat(rtrim(c.kostl), '€€€€€€€€€€'), 1, 10)))), rtrim(c.lstar))), rtrim('€'), rtrim(' €'))), rtrim('€'), rtrim(''))
                when c.objnr_n3 like 'OR%' then concat('OR', rtrim(c.aufnr))
                when c.objnr_n3 like 'PR%' then coalesce(p.objnr, cast('' as VARCHAR))
                else cast('' as VARCHAR)
            end
        )
        else cast('' as VARCHAR)
    end as objnr_n3,
    c.erkrs,
    c.paccas,
    c.paccasty,
    c.pkostl,
    c.plstar,
    c.paufnr,
    c.pautyp,
    c.ppspnr,
    c.ppspid,
    c.pvbeln,
    c.pvbposnr,
    c.pce4key,
    c.quant1,
    c.quant2,
    c.quant3,
    c.qunit1,
    c.qunit2,
    c.qunit3

from acdoca_final as c
left outer join prps_base as p
    on cast(p.mandt as VARCHAR) = cast(c.mandt as VARCHAR)
    and cast(p.posid as VARCHAR) = cast(c.pspnr as VARCHAR)
    and cast(c.mandt as VARCHAR) = cast(p.mandt as VARCHAR)
),
coep_base as (

    select *
    from main_sap.stg_sap__coep

),

acdoca_processed as (

    select *
    from __dbt__cte__int_coep__original

),

original_coep as (

    select
        cast(coep.mandt as VARCHAR) as mandt,
        cast(coep.kokrs as VARCHAR) as kokrs,
        cast(coep.belnr as VARCHAR) as belnr,
        cast(coep.buzei as VARCHAR) as buzei,
        cast(coep.perio as VARCHAR) as perio,
        cast(coep.wtgbtr as NUMERIC) as wtgbtr,
        cast(coep.wogbtr as NUMERIC) as wogbtr,
        cast(coep.wkgbtr as NUMERIC) as wkgbtr,
        cast(coep.wkfbtr as NUMERIC) as wkfbtr,
        cast(coep.pagbtr as NUMERIC) as pagbtr,
        cast(coep.pafbtr as NUMERIC) as pafbtr,
        cast(coep.megbtr as NUMERIC) as megbtr,
        cast(coep.mefbtr as NUMERIC) as mefbtr,
        cast(coep.mbgbtr as NUMERIC) as mbgbtr,
        cast(coep.mbfbtr as NUMERIC) as mbfbtr,
        cast(coep.lednr as VARCHAR) as lednr,
        cast(coep.objnr as VARCHAR) as objnr,
        cast(coep.gjahr as VARCHAR) as gjahr,
        cast(coep.wrttp as VARCHAR) as wrttp,
        cast(coep.versn as VARCHAR) as versn,
        cast(coep.kstar as VARCHAR) as kstar,
        cast(coep.hrkft as VARCHAR) as hrkft,
        cast(coep.vrgng as VARCHAR) as vrgng,
        cast(coep.parob as VARCHAR) as parob,
        cast(coep.parob1 as VARCHAR) as parob1,
        cast(coep.uspob as VARCHAR) as uspob,
        cast(coep.vbund as VARCHAR) as vbund,
        cast(coep.pargb as VARCHAR) as pargb,
        cast(coep.beknz as VARCHAR) as beknz,
        cast(coep.twaer as VARCHAR) as twaer,
        cast(coep.owaer as VARCHAR) as owaer,
        cast(coep.meinh as VARCHAR) as meinh,
        cast(coep.meinb as VARCHAR) as meinb,
        cast(coep.mvflg as VARCHAR) as mvflg,
        cast(coep.sgtxt as VARCHAR) as sgtxt,
        cast(coep.refbz as VARCHAR) as refbz,
        cast(coep.zlenr as VARCHAR) as zlenr,
        cast(coep.bw_refbz as VARCHAR) as bw_refbz,
        cast(coep.gkont as VARCHAR) as gkont,
        cast(coep.gkoar as VARCHAR) as gkoar,
        cast(coep.werks as VARCHAR) as werks,
        cast(coep.matnr as VARCHAR) as matnr,
        cast(coep.rbest as NUMERIC) as rbest,
        cast(coep.ebeln as VARCHAR) as ebeln,
        cast(coep.ebelp as VARCHAR) as ebelp,
        cast(coep.zekkn as VARCHAR) as zekkn,
        cast(coep.erlkz as VARCHAR) as erlkz,
        cast(coep.pernr as VARCHAR) as pernr,
        cast(coep.btrkl as VARCHAR) as btrkl,
        rtrim(cast(coep.objnr_n1 as VARCHAR)) as objnr_n1,
        rtrim(cast(coep.objnr_n2 as VARCHAR)) as objnr_n2,
        rtrim(cast(coep.objnr_n3 as VARCHAR)) as objnr_n3,
        cast(coep.paobjnr as VARCHAR) as paobjnr,
        cast(coep.beltp as VARCHAR) as beltp,
        cast(coep.bukrs as VARCHAR) as bukrs,
        cast(coep.gsber as VARCHAR) as gsber,
        cast(coep.fkber as VARCHAR) as fkber,
        cast(coep.scope as VARCHAR) as scope,
        cast(coep.logsyso as VARCHAR) as logsyso,
        cast(coep.pkstar as VARCHAR) as pkstar,
        cast(coep.pbukrs as VARCHAR) as pbukrs,
        cast(coep.pfkber as VARCHAR) as pfkber,
        cast(coep.pscope as VARCHAR) as pscope,
        cast(coep.logsysp as VARCHAR) as logsysp,
        cast(coep.dabrz as VARCHAR) as dabrz,
        cast(coep.bwstrat as VARCHAR) as bwstrat,
        cast(coep.objnr_hk as VARCHAR) as objnr_hk,
        cast(coep.timestmp as VARCHAR) as timestmp,
        cast(coep.qmnum as VARCHAR) as qmnum,
        cast(coep.geber as VARCHAR) as geber,
        cast(coep.pgeber as VARCHAR) as pgeber,
        cast(coep.grant_nbr as VARCHAR) as grant_nbr,
        cast(coep.pgrant_nbr as VARCHAR) as pgrant_nbr,
        cast(coep.refbz_fi as VARCHAR) as refbz_fi,
        cast(coep.segment as VARCHAR) as segment,
        cast(coep.psegment as VARCHAR) as psegment,
        cast(coep.posnr as VARCHAR) as posnr,
        cast(coep.prctr as VARCHAR) as prctr,
        cast(coep.pprct as VARCHAR) as pprct,
        cast(coep.budget_pd as VARCHAR) as budget_pd,
        cast(coep.pbudget_pd as VARCHAR) as pbudget_pd,
        cast(coep.prodper as VARCHAR) as prodper,
        cast(coep.awtyp as VARCHAR) as awtyp,
        rtrim(cast(coep.awkey as VARCHAR)) as awkey,
        cast(coep.awsys as VARCHAR) as awsys,
        cast(coep.kwaer as VARCHAR) as kwaer,
        cast(coep.accas as VARCHAR) as accas,
        cast(coep.accasty as VARCHAR) as accasty,
        cast(coep.kostl as VARCHAR) as kostl,
        cast(coep.lstar as VARCHAR) as lstar,
        cast(coep.aufnr as VARCHAR) as aufnr,
        cast(coep.autyp as VARCHAR) as autyp,
        cast(coep.pspnr as VARCHAR) as pspnr,
        cast(coep.pspid as VARCHAR) as pspid,
        cast(coep.vbeln as VARCHAR) as vbeln,
        cast(coep.vbposnr as VARCHAR) as vbposnr,
        cast(coep.ce4key as VARCHAR) as ce4key,
        cast(coep.erkrs as VARCHAR) as erkrs,
        cast(coep.paccas as VARCHAR) as paccas,
        cast(coep.paccasty as VARCHAR) as paccasty,
        cast(coep.pkostl as VARCHAR) as pkostl,
        cast(coep.plstar as VARCHAR) as plstar,
        cast(coep.paufnr as VARCHAR) as paufnr,
        cast(coep.pautyp as VARCHAR) as pautyp,
        cast(coep.ppspnr as VARCHAR) as ppspnr,
        cast(coep.ppspid as VARCHAR) as ppspid,
        cast(coep.pvbeln as VARCHAR) as pvbeln,
        cast(coep.pvbposnr as VARCHAR) as pvbposnr,
        cast(coep.pce4key as VARCHAR) as pce4key,
        cast(coep.quant1 as NUMERIC) as quant1,
        cast(coep.quant2 as NUMERIC) as quant2,
        cast(coep.quant3 as NUMERIC) as quant3,
        cast(coep.qunit1 as VARCHAR) as qunit1,
        cast(coep.qunit2 as VARCHAR) as qunit2,
        cast(coep.qunit3 as VARCHAR) as qunit3

    from coep_base as coep
    where not (cast(coep.wrttp as VARCHAR) = '04' or cast(coep.wrttp as VARCHAR) = 'U4' or cast(coep.wrttp as VARCHAR) = 'U1')

),

derived_acdoca as (

    select
        cast(acdoca_processed.mandt as VARCHAR) as mandt,
        cast(acdoca_processed.kokrs as VARCHAR) as kokrs,
        cast(acdoca_processed.belnr as VARCHAR) as belnr,
        cast(acdoca_processed.buzei as VARCHAR) as buzei,
        cast(acdoca_processed.perio as VARCHAR) as perio,
        cast(acdoca_processed.wtgbtr as NUMERIC) as wtgbtr,
        cast(acdoca_processed.wogbtr as NUMERIC) as wogbtr,
        cast(acdoca_processed.wkgbtr as NUMERIC) as wkgbtr,
        cast(acdoca_processed.wkfbtr as NUMERIC) as wkfbtr,
        cast(acdoca_processed.pagbtr as NUMERIC) as pagbtr,
        cast(acdoca_processed.pafbtr as NUMERIC) as pafbtr,
        cast(acdoca_processed.megbtr as NUMERIC) as megbtr,
        cast(acdoca_processed.mefbtr as NUMERIC) as mefbtr,
        cast(acdoca_processed.mbgbtr as NUMERIC) as mbgbtr,
        cast(acdoca_processed.mbfbtr as NUMERIC) as mbfbtr,
        cast(acdoca_processed.lednr as VARCHAR) as lednr,
        cast(acdoca_processed.objnr as VARCHAR) as objnr,
        cast(acdoca_processed.gjahr as VARCHAR) as gjahr,
        cast('04' as VARCHAR) as wrttp,
        cast(acdoca_processed.versn as VARCHAR) as versn,
        cast(acdoca_processed.kstar as VARCHAR) as kstar,
        cast(acdoca_processed.hrkft as VARCHAR) as hrkft,
        cast(acdoca_processed.vrgng as VARCHAR) as vrgng,
        cast(acdoca_processed.parob as VARCHAR) as parob,
        cast(acdoca_processed.parob1 as VARCHAR) as parob1,
        cast(acdoca_processed.uspob as VARCHAR) as uspob,
        cast(acdoca_processed.vbund as VARCHAR) as vbund,
        cast(acdoca_processed.pargb as VARCHAR) as pargb,
        cast(acdoca_processed.beknz as VARCHAR) as beknz,
        cast(acdoca_processed.twaer as VARCHAR) as twaer,
        cast(acdoca_processed.owaer as VARCHAR) as owaer,
        cast(acdoca_processed.meinh as VARCHAR) as meinh,
        cast(acdoca_processed.meinb as VARCHAR) as meinb,
        case
            when cast(acdoca_processed.mvflg as VARCHAR) = '0' then cast('X' as VARCHAR)
            else cast('' as VARCHAR)
        end as mvflg,
        cast(acdoca_processed.sgtxt as VARCHAR) as sgtxt,
        cast(acdoca_processed.refbz as VARCHAR) as refbz,
        cast(acdoca_processed.zlenr as VARCHAR) as zlenr,
        cast(acdoca_processed.bw_refbz as VARCHAR) as bw_refbz,
        cast(acdoca_processed.gkont as VARCHAR) as gkont,
        cast(acdoca_processed.gkoar as VARCHAR) as gkoar,
        cast(acdoca_processed.werks as VARCHAR) as werks,
        cast(acdoca_processed.matnr as VARCHAR) as matnr,
        cast(acdoca_processed.rbest as NUMERIC) as rbest,
        cast(acdoca_processed.ebeln as VARCHAR) as ebeln,
        cast(acdoca_processed.ebelp as VARCHAR) as ebelp,
        cast(acdoca_processed.zekkn as VARCHAR) as zekkn,
        cast(acdoca_processed.erlkz as VARCHAR) as erlkz,
        cast(acdoca_processed.pernr as VARCHAR) as pernr,
        cast('00' as VARCHAR) as btrkl,
        rtrim(cast(acdoca_processed.objnr_n1 as VARCHAR)) as objnr_n1,
        rtrim(cast(acdoca_processed.objnr_n2 as VARCHAR)) as objnr_n2,
        rtrim(cast(acdoca_processed.objnr_n3 as VARCHAR)) as objnr_n3,
        cast(acdoca_processed.paobjnr as VARCHAR) as paobjnr,
        cast(acdoca_processed.beltp as VARCHAR) as beltp,
        cast(acdoca_processed.bukrs as VARCHAR) as bukrs,
        cast(acdoca_processed.gsber as VARCHAR) as gsber,
        cast(acdoca_processed.fkber as VARCHAR) as fkber,
        cast(acdoca_processed.scope as VARCHAR) as scope,
        cast(acdoca_processed.logsyso as VARCHAR) as logsyso,
        cast(acdoca_processed.pkstar as VARCHAR) as pkstar,
        cast(acdoca_processed.pbukrs as VARCHAR) as pbukrs,
        cast(acdoca_processed.pfkber as VARCHAR) as pfkber,
        cast(acdoca_processed.pscope as VARCHAR) as pscope,
        cast(acdoca_processed.logsysp as VARCHAR) as logsysp,
        cast(acdoca_processed.dabrz as VARCHAR) as dabrz,
        cast(acdoca_processed.bwstrat as VARCHAR) as bwstrat,
        cast(acdoca_processed.objnr_hk as VARCHAR) as objnr_hk,
        cast(acdoca_processed.timestmp as VARCHAR) as timestmp,
        cast(acdoca_processed.qmnum as VARCHAR) as qmnum,
        cast(acdoca_processed.geber as VARCHAR) as geber,
        cast(acdoca_processed.pgeber as VARCHAR) as pgeber,
        cast(acdoca_processed.grant_nbr as VARCHAR) as grant_nbr,
        cast(acdoca_processed.pgrant_nbr as VARCHAR) as pgrant_nbr,
        cast(acdoca_processed.refbz_fi as VARCHAR) as refbz_fi,
        cast(acdoca_processed.segment as VARCHAR) as segment,
        cast(acdoca_processed.psegment as VARCHAR) as psegment,
        cast(acdoca_processed.posnr as VARCHAR) as posnr,
        cast(acdoca_processed.prctr as VARCHAR) as prctr,
        cast(acdoca_processed.pprct as VARCHAR) as pprct,
        cast(acdoca_processed.budget_pd as VARCHAR) as budget_pd,
        cast(acdoca_processed.pbudget_pd as VARCHAR) as pbudget_pd,
        cast(acdoca_processed.prodper as VARCHAR) as prodper,
        cast(acdoca_processed.awtyp as VARCHAR) as awtyp,
        rtrim(cast(acdoca_processed.awkey as VARCHAR)) as awkey,
        cast(acdoca_processed.awsys as VARCHAR) as awsys,
        cast(acdoca_processed.kwaer as VARCHAR) as kwaer,
        cast(acdoca_processed.accas as VARCHAR) as accas,
        cast(acdoca_processed.accasty as VARCHAR) as accasty,
        cast(acdoca_processed.kostl as VARCHAR) as kostl,
        cast(acdoca_processed.lstar as VARCHAR) as lstar,
        cast(acdoca_processed.aufnr as VARCHAR) as aufnr,
        cast(acdoca_processed.autyp as VARCHAR) as autyp,
        cast(acdoca_processed.pspnr as VARCHAR) as pspnr,
        cast(acdoca_processed.pspid as VARCHAR) as pspid,
        cast(acdoca_processed.vbeln as VARCHAR) as vbeln,
        cast(acdoca_processed.vbposnr as VARCHAR) as vbposnr,
        cast(acdoca_processed.ce4key as VARCHAR) as ce4key,
        cast(acdoca_processed.erkrs as VARCHAR) as erkrs,
        cast(acdoca_processed.paccas as VARCHAR) as paccas,
        cast(acdoca_processed.paccasty as VARCHAR) as paccasty,
        cast(acdoca_processed.pkostl as VARCHAR) as pkostl,
        cast(acdoca_processed.plstar as VARCHAR) as plstar,
        cast(acdoca_processed.paufnr as VARCHAR) as paufnr,
        cast(acdoca_processed.pautyp as VARCHAR) as pautyp,
        cast(acdoca_processed.ppspnr as VARCHAR) as ppspnr,
        cast(acdoca_processed.ppspid as VARCHAR) as ppspid,
        cast(acdoca_processed.pvbeln as VARCHAR) as pvbeln,
        cast(acdoca_processed.pvbposnr as VARCHAR) as pvbposnr,
        cast(acdoca_processed.pce4key as VARCHAR) as pce4key,
        cast(acdoca_processed.quant1 as NUMERIC) as quant1,
        cast(acdoca_processed.quant2 as NUMERIC) as quant2,
        cast(acdoca_processed.quant3 as NUMERIC) as quant3,
        cast(acdoca_processed.qunit1 as VARCHAR) as qunit1,
        cast(acdoca_processed.qunit2 as VARCHAR) as qunit2,
        cast(acdoca_processed.qunit3 as VARCHAR) as qunit3

    from acdoca_processed

),

final_union as (

    select * from original_coep
    union all
    select * from derived_acdoca

)

select * from final_union
