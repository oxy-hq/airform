with base as (

    select 
    from "sap"."main_sap"."stg_sap__mara_tmp"
),

fields as (

    select
        
    cast(null as TEXT) as _accgo_assgd_uom , 
    cast(null as TEXT) as _bev1_luldegrp , 
    cast(null as TEXT) as _bev1_luleinh , 
    cast(null as TEXT) as _bev1_nestruccat , 
    cast(null as TEXT) as _dsd_sl_toltyp , 
    cast(null as TEXT) as _dsd_sv_cnt_grp , 
    cast(null as TEXT) as _dsd_vc_group , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as numeric(28,6)) as 
    
    _fivetran_rowid
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as _sttpec_country_ref , 
    cast(null as TEXT) as _sttpec_prdcat , 
    cast(null as numeric(28,6)) as _sttpec_sertype , 
    cast(null as TEXT) as _sttpec_syncact , 
    cast(null as TEXT) as _sttpec_syncchg , 
    cast(null as numeric(28,6)) as _sttpec_synctime , 
    cast(null as TEXT) as _vso_r_bot_ind , 
    cast(null as TEXT) as _vso_r_kzgvh_ind , 
    cast(null as TEXT) as _vso_r_no_p_gvh , 
    cast(null as numeric(28,6)) as _vso_r_pal_b_ht , 
    cast(null as TEXT) as _vso_r_pal_ind , 
    cast(null as numeric(28,6)) as _vso_r_pal_min_h , 
    cast(null as numeric(28,6)) as _vso_r_pal_ovr_d , 
    cast(null as numeric(28,6)) as _vso_r_pal_ovr_w , 
    cast(null as TEXT) as _vso_r_quan_unit , 
    cast(null as TEXT) as _vso_r_stack_ind , 
    cast(null as TEXT) as _vso_r_stack_no , 
    cast(null as TEXT) as _vso_r_tilt_ind , 
    cast(null as numeric(28,6)) as _vso_r_tol_b_ht , 
    cast(null as TEXT) as _vso_r_top_ind , 
    cast(null as TEXT) as 
    
    adprof
    
 , 
    cast(null as TEXT) as 
    
    adspc_spc
    
 , 
    cast(null as TEXT) as 
    
    aeklk
    
 , 
    cast(null as TEXT) as 
    
    aenam
    
 , 
    cast(null as TEXT) as 
    
    aeszn
    
 , 
    cast(null as TEXT) as 
    
    allow_pmat_igno
    
 , 
    cast(null as TEXT) as 
    
    animal_origin
    
 , 
    cast(null as TEXT) as 
    
    anp
    
 , 
    cast(null as TEXT) as 
    
    attyp
    
 , 
    cast(null as TEXT) as 
    
    bbtyp
    
 , 
    cast(null as TEXT) as 
    
    begru
    
 , 
    cast(null as TEXT) as 
    
    behvo
    
 , 
    cast(null as TEXT) as 
    
    bflme
    
 , 
    cast(null as TEXT) as 
    
    bismt
    
 , 
    cast(null as TEXT) as 
    
    blanz
    
 , 
    cast(null as TEXT) as 
    
    blatt
    
 , 
    cast(null as TEXT) as 
    
    bmatn
    
 , 
    cast(null as TEXT) as 
    
    brand_id
    
 , 
    cast(null as numeric(28,6)) as 
    
    breit
    
 , 
    cast(null as numeric(28,6)) as 
    
    brgew
    
 , 
    cast(null as TEXT) as 
    
    bstat
    
 , 
    cast(null as TEXT) as 
    
    bstme
    
 , 
    cast(null as TEXT) as 
    
    bwscl
    
 , 
    cast(null as TEXT) as 
    
    bwvor
    
 , 
    cast(null as TEXT) as 
    
    cadkz
    
 , 
    cast(null as TEXT) as 
    
    care_code
    
 , 
    cast(null as TEXT) as 
    
    cmeth
    
 , 
    cast(null as TEXT) as 
    
    cmrel
    
 , 
    cast(null as TEXT) as 
    
    cobjid
    
 , 
    cast(null as TEXT) as 
    
    color_atinn
    
 , 
    cast(null as TEXT) as 
    
    color
    
 , 
    cast(null as TEXT) as 
    
    commodity
    
 , 
    cast(null as TEXT) as 
    
    compl
    
 , 
    cast(null as TEXT) as 
    
    cotype
    
 , 
    cast(null as TEXT) as 
    
    cuobf
    
 , 
    cast(null as TEXT) as 
    
    cwqproc
    
 , 
    cast(null as TEXT) as 
    
    cwqrel
    
 , 
    cast(null as TEXT) as 
    
    cwqtolgr
    
 , 
    cast(null as TEXT) as 
    
    datab
    
 , 
    cast(null as TEXT) as 
    
    dg_pack_status
    
 , 
    cast(null as TEXT) as 
    
    disst
    
 , 
    cast(null as TEXT) as 
    
    ean11
    
 , 
    cast(null as TEXT) as 
    
    eannr
    
 , 
    cast(null as TEXT) as 
    
    ekwsl
    
 , 
    cast(null as TEXT) as 
    
    entar
    
 , 
    cast(null as TEXT) as 
    
    ergei
    
 , 
    cast(null as numeric(28,6)) as 
    
    ergew
    
 , 
    cast(null as TEXT) as 
    
    ernam
    
 , 
    cast(null as TEXT) as 
    
    ersda
    
 , 
    cast(null as TEXT) as 
    
    ervoe
    
 , 
    cast(null as numeric(28,6)) as 
    
    ervol
    
 , 
    cast(null as TEXT) as 
    
    etiag
    
 , 
    cast(null as TEXT) as 
    
    etiar
    
 , 
    cast(null as TEXT) as 
    
    etifo
    
 , 
    cast(null as TEXT) as 
    
    extwg
    
 , 
    cast(null as TEXT) as 
    
    fashgrd
    
 , 
    cast(null as TEXT) as 
    
    ferth
    
 , 
    cast(null as TEXT) as 
    
    fiber_code1
    
 , 
    cast(null as TEXT) as 
    
    fiber_code2
    
 , 
    cast(null as TEXT) as 
    
    fiber_code3
    
 , 
    cast(null as TEXT) as 
    
    fiber_code4
    
 , 
    cast(null as TEXT) as 
    
    fiber_code5
    
 , 
    cast(null as TEXT) as 
    
    fiber_part1
    
 , 
    cast(null as TEXT) as 
    
    fiber_part2
    
 , 
    cast(null as TEXT) as 
    
    fiber_part3
    
 , 
    cast(null as TEXT) as 
    
    fiber_part4
    
 , 
    cast(null as TEXT) as 
    
    fiber_part5
    
 , 
    cast(null as TEXT) as 
    
    formt
    
 , 
    cast(null as TEXT) as 
    
    free_char
    
 , 
    cast(null as TEXT) as 
    
    fsh_mg_at1
    
 , 
    cast(null as TEXT) as 
    
    fsh_mg_at2
    
 , 
    cast(null as TEXT) as 
    
    fsh_mg_at3
    
 , 
    cast(null as TEXT) as 
    
    fsh_sc_mid
    
 , 
    cast(null as TEXT) as 
    
    fsh_seaim
    
 , 
    cast(null as TEXT) as 
    
    fsh_sealv
    
 , 
    cast(null as numeric(28,6)) as 
    
    fuelg
    
 , 
    cast(null as TEXT) as 
    
    gds_relevant
    
 , 
    cast(null as TEXT) as 
    
    gennr
    
 , 
    cast(null as TEXT) as 
    
    gewei
    
 , 
    cast(null as numeric(28,6)) as 
    
    gewto
    
 , 
    cast(null as TEXT) as 
    
    groes
    
 , 
    cast(null as TEXT) as 
    
    gtin_variant
    
 , 
    cast(null as TEXT) as 
    
    hazmat
    
 , 
    cast(null as TEXT) as 
    
    herkl
    
 , 
    cast(null as TEXT) as 
    
    hndlcode
    
 , 
    cast(null as numeric(28,6)) as 
    
    hoehe
    
 , 
    cast(null as TEXT) as 
    
    hutyp_dflt
    
 , 
    cast(null as TEXT) as 
    
    hutyp
    
 , 
    cast(null as TEXT) as 
    
    ihivi
    
 , 
    cast(null as TEXT) as 
    
    iloos
    
 , 
    cast(null as TEXT) as 
    
    imatn
    
 , 
    cast(null as numeric(28,6)) as 
    
    inhal
    
 , 
    cast(null as numeric(28,6)) as 
    
    inhbr
    
 , 
    cast(null as TEXT) as 
    
    inhme
    
 , 
    cast(null as TEXT) as 
    
    ipmipproduct
    
 , 
    cast(null as TEXT) as 
    
    iprkz
    
 , 
    cast(null as TEXT) as 
    
    kosch
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    kzeff
    
 , 
    cast(null as TEXT) as 
    
    kzgvh
    
 , 
    cast(null as TEXT) as 
    
    kzkfg
    
 , 
    cast(null as TEXT) as 
    
    kzkup
    
 , 
    cast(null as TEXT) as 
    
    kznfm
    
 , 
    cast(null as TEXT) as 
    
    kzrev
    
 , 
    cast(null as TEXT) as 
    
    kzumw
    
 , 
    cast(null as TEXT) as 
    
    kzwsm
    
 , 
    cast(null as TEXT) as 
    
    labor
    
 , 
    cast(null as TEXT) as 
    
    laeda
    
 , 
    cast(null as numeric(28,6)) as 
    
    laeng
    
 , 
    cast(null as TEXT) as 
    
    liqdt
    
 , 
    cast(null as TEXT) as 
    
    loglev_reto
    
 , 
    cast(null as TEXT) as 
    
    logunit
    
 , 
    cast(null as TEXT) as 
    
    lvorm
    
 , 
    cast(null as TEXT) as 
    
    magrv
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    matfi
    
 , 
    cast(null as TEXT) as 
    
    matkl
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxb
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxc_tol
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxc
    
 , 
    cast(null as TEXT) as 
    
    maxdim_uom
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxh
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxl
    
 , 
    cast(null as TEXT) as 
    
    mbrsh
    
 , 
    cast(null as TEXT) as 
    
    mcond
    
 , 
    cast(null as TEXT) as 
    
    meabm
    
 , 
    cast(null as TEXT) as 
    
    medium
    
 , 
    cast(null as TEXT) as 
    
    meins
    
 , 
    cast(null as TEXT) as 
    
    mfrgr
    
 , 
    cast(null as TEXT) as 
    
    mfrnr
    
 , 
    cast(null as TEXT) as 
    
    mfrpn
    
 , 
    cast(null as numeric(28,6)) as 
    
    mhdhb
    
 , 
    cast(null as numeric(28,6)) as 
    
    mhdlp
    
 , 
    cast(null as numeric(28,6)) as 
    
    mhdrz
    
 , 
    cast(null as TEXT) as 
    
    mlgut
    
 , 
    cast(null as TEXT) as 
    
    mprof
    
 , 
    cast(null as TEXT) as 
    
    mstae
    
 , 
    cast(null as TEXT) as 
    
    mstav
    
 , 
    cast(null as TEXT) as 
    
    mstde
    
 , 
    cast(null as TEXT) as 
    
    mstdv
    
 , 
    cast(null as TEXT) as 
    
    mtart
    
 , 
    cast(null as TEXT) as 
    
    mtpos_mara
    
 , 
    cast(null as TEXT) as 
    
    normt
    
 , 
    cast(null as TEXT) as 
    
    nrfhg
    
 , 
    cast(null as TEXT) as 
    
    nsnid
    
 , 
    cast(null as numeric(28,6)) as 
    
    ntgew
    
 , 
    cast(null as TEXT) as 
    
    numtp
    
 , 
    cast(null as TEXT) as 
    
    oigroupnam
    
 , 
    cast(null as TEXT) as 
    
    oihmtxgr
    
 , 
    cast(null as TEXT) as 
    
    oitrind
    
 , 
    cast(null as TEXT) as 
    
    packcode
    
 , 
    cast(null as TEXT) as 
    
    picnum
    
 , 
    cast(null as TEXT) as 
    
    pilferable
    
 , 
    cast(null as TEXT) as 
    
    plgtp
    
 , 
    cast(null as TEXT) as 
    
    pmata
    
 , 
    cast(null as TEXT) as 
    
    prdha
    
 , 
    cast(null as TEXT) as 
    
    profl
    
 , 
    cast(null as TEXT) as 
    
    przus
    
 , 
    cast(null as TEXT) as 
    
    ps_smartform
    
 , 
    cast(null as TEXT) as 
    
    psm_code
    
 , 
    cast(null as TEXT) as 
    
    pstat
    
 , 
    cast(null as TEXT) as 
    
    qgrp
    
 , 
    cast(null as TEXT) as 
    
    qmpur
    
 , 
    cast(null as numeric(28,6)) as 
    
    qqtime
    
 , 
    cast(null as TEXT) as 
    
    qqtimeuom
    
 , 
    cast(null as TEXT) as 
    
    raube
    
 , 
    cast(null as TEXT) as 
    
    rbnrm
    
 , 
    cast(null as TEXT) as 
    
    rdmhd
    
 , 
    cast(null as TEXT) as 
    
    retdelc
    
 , 
    cast(null as TEXT) as 
    
    rmatp
    
 , 
    cast(null as TEXT) as 
    
    saisj
    
 , 
    cast(null as TEXT) as 
    
    saiso
    
 , 
    cast(null as TEXT) as 
    
    saity
    
 , 
    cast(null as TEXT) as 
    
    satnr
    
 , 
    cast(null as TEXT) as 
    
    serial
    
 , 
    cast(null as TEXT) as 
    
    serlv
    
 , 
    cast(null as TEXT) as 
    
    sgt_covsa
    
 , 
    cast(null as TEXT) as 
    
    sgt_csgr
    
 , 
    cast(null as TEXT) as 
    
    sgt_rel
    
 , 
    cast(null as TEXT) as 
    
    sgt_scope
    
 , 
    cast(null as TEXT) as 
    
    sgt_stat
    
 , 
    cast(null as TEXT) as 
    
    size1_atinn
    
 , 
    cast(null as TEXT) as 
    
    size1
    
 , 
    cast(null as TEXT) as 
    
    size2_atinn
    
 , 
    cast(null as TEXT) as 
    
    size2
    
 , 
    cast(null as TEXT) as 
    
    sled_bbd
    
 , 
    cast(null as TEXT) as 
    
    spart
    
 , 
    cast(null as TEXT) as 
    
    sprof
    
 , 
    cast(null as numeric(28,6)) as 
    
    stfak
    
 , 
    cast(null as TEXT) as 
    
    stoff
    
 , 
    cast(null as TEXT) as 
    
    taklv
    
 , 
    cast(null as TEXT) as 
    
    tare_var
    
 , 
    cast(null as TEXT) as 
    
    tempb
    
 , 
    cast(null as TEXT) as 
    
    textile_comp_ind
    
 , 
    cast(null as TEXT) as 
    
    tragr
    
 , 
    cast(null as TEXT) as 
    
    vabme
    
 , 
    cast(null as TEXT) as 
    
    vhart
    
 , 
    cast(null as TEXT) as 
    
    voleh
    
 , 
    cast(null as numeric(28,6)) as 
    
    volto
    
 , 
    cast(null as numeric(28,6)) as 
    
    volum
    
 , 
    cast(null as numeric(28,6)) as 
    
    vpreh
    
 , 
    cast(null as TEXT) as 
    
    vpsta
    
 , 
    cast(null as TEXT) as 
    
    weora
    
 , 
    cast(null as numeric(28,6)) as 
    
    wesch
    
 , 
    cast(null as TEXT) as 
    
    whmatgr
    
 , 
    cast(null as TEXT) as 
    
    whstc
    
 , 
    cast(null as TEXT) as 
    
    wrkst
    
 , 
    cast(null as TEXT) as 
    
    xchpf
    
 , 
    cast(null as TEXT) as 
    
    xgchp
    
 , 
    cast(null as TEXT) as 
    
    zeiar
    
 , 
    cast(null as TEXT) as 
    
    zeifo
    
 , 
    cast(null as TEXT) as 
    
    zeinr
    
 , 
    cast(null as TEXT) as 
    
    zeivr
    
 


    from base
),

final as (

    select
        _accgo_assgd_uom,
        _bev1_luldegrp,
        _bev1_luleinh,
        _bev1_nestruccat,
        _dsd_sl_toltyp,
        _dsd_sv_cnt_grp,
        _dsd_vc_group,
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_sap_archived,
        _fivetran_synced,
        _sttpec_country_ref,
        _sttpec_prdcat,
        _sttpec_sertype,
        _sttpec_syncact,
        _sttpec_syncchg,
        _sttpec_synctime,
        _vso_r_bot_ind,
        _vso_r_kzgvh_ind,
        _vso_r_no_p_gvh,
        _vso_r_pal_b_ht,
        _vso_r_pal_ind,
        _vso_r_pal_min_h,
        _vso_r_pal_ovr_d,
        _vso_r_pal_ovr_w,
        _vso_r_quan_unit,
        _vso_r_stack_ind,
        _vso_r_stack_no,
        _vso_r_tilt_ind,
        _vso_r_tol_b_ht,
        _vso_r_top_ind,
        adprof,
        adspc_spc,
        aeklk,
        aenam,
        aeszn,
        allow_pmat_igno,
        animal_origin,
        anp,
        attyp,
        bbtyp,
        begru,
        behvo,
        bflme,
        bismt,
        blanz,
        blatt,
        bmatn,
        brand_id,
        breit,
        brgew,
        bstat,
        bstme,
        bwscl,
        bwvor,
        cadkz,
        care_code,
        cmeth,
        cmrel,
        cobjid,
        color_atinn,
        color,
        commodity,
        compl,
        cotype,
        cuobf,
        cwqproc,
        cwqrel,
        cwqtolgr,
        datab,
        dg_pack_status,
        disst,
        ean11,
        eannr,
        ekwsl,
        entar,
        ergei,
        ergew,
        ernam,
        ersda,
        ervoe,
        ervol,
        etiag,
        etiar,
        etifo,
        extwg,
        fashgrd,
        ferth,
        fiber_code1,
        fiber_code2,
        fiber_code3,
        fiber_code4,
        fiber_code5,
        fiber_part1,
        fiber_part2,
        fiber_part3,
        fiber_part4,
        fiber_part5,
        formt,
        free_char,
        fsh_mg_at1,
        fsh_mg_at2,
        fsh_mg_at3,
        fsh_sc_mid,
        fsh_seaim,
        fsh_sealv,
        fuelg,
        gds_relevant,
        gennr,
        gewei,
        gewto,
        groes,
        gtin_variant,
        hazmat,
        herkl,
        hndlcode,
        hoehe,
        hutyp_dflt,
        hutyp,
        ihivi,
        iloos,
        imatn,
        inhal,
        inhbr,
        inhme,
        ipmipproduct,
        iprkz,
        kosch,
        cast(kunnr as TEXT) as kunnr,
        kzeff,
        kzgvh,
        kzkfg,
        kzkup,
        kznfm,
        kzrev,
        kzumw,
        kzwsm,
        labor,
        laeda,
        laeng,
        liqdt,
        loglev_reto,
        logunit,
        lvorm,
        magrv,
        cast(mandt as TEXT) as mandt,
        matfi,
        matkl,
        cast(matnr as TEXT) as matnr,
        maxb,
        maxc_tol,
        maxc,
        maxdim_uom,
        maxh,
        maxl,
        mbrsh,
        mcond,
        meabm,
        medium,
        meins,
        mfrgr,
        mfrnr,
        mfrpn,
        mhdhb,
        mhdlp,
        mhdrz,
        mlgut,
        mprof,
        mstae,
        mstav,
        mstde,
        mstdv,
        mtart,
        mtpos_mara,
        normt,
        nrfhg,
        nsnid,
        ntgew,
        numtp,
        oigroupnam,
        oihmtxgr,
        oitrind,
        packcode,
        picnum,
        pilferable,
        plgtp,
        pmata,
        prdha,
        profl,
        przus,
        ps_smartform,
        psm_code,
        pstat,
        qgrp,
        qmpur,
        qqtime,
        qqtimeuom,
        raube,
        rbnrm,
        rdmhd,
        retdelc,
        rmatp,
        saisj,
        saiso,
        saity,
        satnr,
        serial,
        serlv,
        sgt_covsa,
        sgt_csgr,
        sgt_rel,
        sgt_scope,
        sgt_stat,
        size1_atinn,
        size1,
        size2_atinn,
        size2,
        sled_bbd,
        spart,
        sprof,
        stfak,
        stoff,
        taklv,
        tare_var,
        tempb,
        textile_comp_ind,
        tragr,
        vabme,
        vhart,
        voleh,
        volto,
        volum,
        vpreh,
        vpsta,
        weora,
        wesch,
        whmatgr,
        whstc,
        wrkst,
        xchpf,
        xgchp,
        zeiar,
        zeifo,
        zeinr,
        zeivr
    from fields
)

select *
from final
