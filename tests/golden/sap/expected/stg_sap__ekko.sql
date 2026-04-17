with base as (
    select 
    from "sap"."main_sap"."stg_sap__ekko_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    abgru
    
 , 
    cast(null as TEXT) as 
    
    absgr
    
 , 
    cast(null as TEXT) as 
    
    addnr
    
 , 
    cast(null as TEXT) as 
    
    adrnr
    
 , 
    cast(null as TEXT) as 
    
    aedat
    
 , 
    cast(null as TEXT) as 
    
    angdt
    
 , 
    cast(null as TEXT) as 
    
    angnr
    
 , 
    cast(null as TEXT) as 
    
    aurel_allow
    
 , 
    cast(null as TEXT) as 
    
    ausnr
    
 , 
    cast(null as TEXT) as 
    
    autlf
    
 , 
    cast(null as TEXT) as 
    
    bedat
    
 , 
    cast(null as TEXT) as 
    
    bnddt
    
 , 
    cast(null as TEXT) as 
    
    bsakz
    
 , 
    cast(null as TEXT) as 
    
    bsart
    
 , 
    cast(null as TEXT) as 
    
    bstyp
    
 , 
    cast(null as TEXT) as 
    
    bwbdt
    
 , 
    cast(null as TEXT) as 
    
    budg_type
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    check_type
    
 , 
    cast(null as TEXT) as 
    
    con_distr_lev
    
 , 
    cast(null as TEXT) as 
    
    con_otb_req
    
 , 
    cast(null as TEXT) as 
    
    con_prebook_lev
    
 , 
    cast(null as TEXT) as 
    
    contract_allow
    
 , 
    cast(null as TEXT) as 
    
    delper_allow
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as TEXT) as 
    
    dpamt
    
 , 
    cast(null as TEXT) as 
    
    dpdat
    
 , 
    cast(null as TEXT) as 
    
    dppct
    
 , 
    cast(null as TEXT) as 
    
    dptyp
    
 , 
    cast(null as TEXT) as 
    
    ebeln
    
 , 
    cast(null as TEXT) as 
    
    eindt
    
 , 
    cast(null as TEXT) as 
    
    eindt_allow
    
 , 
    cast(null as TEXT) as 
    
    ekgrp
    
 , 
    cast(null as TEXT) as 
    
    ekgrp_allow
    
 , 
    cast(null as TEXT) as 
    
    ekorg
    
 , 
    cast(null as TEXT) as 
    
    eq_eindt
    
 , 
    cast(null as TEXT) as 
    
    eq_werks
    
 , 
    cast(null as TEXT) as 
    
    ernam
    
 , 
    cast(null as TEXT) as 
    
    exnum
    
 , 
    cast(null as TEXT) as 
    
    fixpo
    
 , 
    cast(null as TEXT) as 
    
    fixpo_allow
    
 , 
    cast(null as TEXT) as 
    
    force_cnt
    
 , 
    cast(null as TEXT) as 
    
    force_id
    
 , 
    cast(null as TEXT) as 
    
    frggr
    
 , 
    cast(null as TEXT) as 
    
    frgke
    
 , 
    cast(null as TEXT) as 
    
    frgrl
    
 , 
    cast(null as TEXT) as 
    
    frgsx
    
 , 
    cast(null as TEXT) as 
    
    frgzu
    
 , 
    cast(null as TEXT) as 
    
    fsh_item_group
    
 , 
    cast(null as TEXT) as 
    
    fsh_os_stg_change
    
 , 
    cast(null as TEXT) as 
    
    fsh_snst_status
    
 , 
    cast(null as TEXT) as 
    
    fsh_transaction
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_last_item
    
 , 
    cast(null as TEXT) as 
    
    gwldt
    
 , 
    cast(null as TEXT) as 
    
    handoverloc
    
 , 
    cast(null as TEXT) as 
    
    hierarchy_exists
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    ihran
    
 , 
    cast(null as TEXT) as 
    
    ihrez
    
 , 
    cast(null as TEXT) as 
    
    inco1
    
 , 
    cast(null as TEXT) as 
    
    inco2
    
 , 
    cast(null as TEXT) as 
    
    inco2_l
    
 , 
    cast(null as TEXT) as 
    
    inco3_l
    
 , 
    cast(null as TEXT) as 
    
    incov
    
 , 
    cast(null as TEXT) as 
    
    kalsm
    
 , 
    cast(null as TEXT) as 
    
    kdatb
    
 , 
    cast(null as TEXT) as 
    
    kdate
    
 , 
    cast(null as TEXT) as 
    
    key_id
    
 , 
    cast(null as TEXT) as 
    
    key_id_allow
    
 , 
    cast(null as TEXT) as 
    
    knumv
    
 , 
    cast(null as TEXT) as 
    
    konnr
    
 , 
    cast(null as TEXT) as 
    
    kornr
    
 , 
    cast(null as TEXT) as 
    
    ktwrt
    
 , 
    cast(null as TEXT) as 
    
    kufix
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    lands
    
 , 
    cast(null as TEXT) as 
    
    lblif
    
 , 
    cast(null as TEXT) as 
    
    legal_contract
    
 , 
    cast(null as TEXT) as 
    
    lifnr
    
 , 
    cast(null as TEXT) as 
    
    lifre
    
 , 
    cast(null as TEXT) as 
    
    llief
    
 , 
    cast(null as TEXT) as 
    
    loekz
    
 , 
    cast(null as TEXT) as 
    
    logsy
    
 , 
    cast(null as TEXT) as 
    
    lphis
    
 , 
    cast(null as TEXT) as 
    
    lponr
    
 , 
    cast(null as TEXT) as 
    
    ltsnr_allow
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    memory
    
 , 
    cast(null as TEXT) as 
    
    memorytype
    
 , 
    cast(null as TEXT) as 
    
    msr_id
    
 , 
    cast(null as TEXT) as 
    
    otb_cond_type
    
 , 
    cast(null as TEXT) as 
    
    otb_curr
    
 , 
    cast(null as TEXT) as 
    
    otb_level
    
 , 
    cast(null as TEXT) as 
    
    otb_reason
    
 , 
    cast(null as TEXT) as 
    
    otb_res_value
    
 , 
    cast(null as TEXT) as 
    
    otb_spec_value
    
 , 
    cast(null as TEXT) as 
    
    otb_status
    
 , 
    cast(null as TEXT) as 
    
    otb_value
    
 , 
    cast(null as TEXT) as 
    
    pincr
    
 , 
    cast(null as TEXT) as 
    
    pohf_type
    
 , 
    cast(null as TEXT) as 
    
    procstat
    
 , 
    cast(null as TEXT) as 
    
    pstyp_allow
    
 , 
    cast(null as TEXT) as 
    
    release_date
    
 , 
    cast(null as TEXT) as 
    
    reason_code
    
 , 
    cast(null as TEXT) as 
    
    reloc_id
    
 , 
    cast(null as TEXT) as 
    
    reloc_seq_id
    
 , 
    cast(null as TEXT) as 
    
    reswk
    
 , 
    cast(null as TEXT) as 
    
    retpc
    
 , 
    cast(null as TEXT) as 
    
    rettp
    
 , 
    cast(null as TEXT) as 
    
    revno
    
 , 
    cast(null as TEXT) as 
    
    rlwrt
    
 , 
    cast(null as TEXT) as 
    
    scmproc
    
 , 
    cast(null as TEXT) as 
    
    shipcond
    
 , 
    cast(null as TEXT) as 
    
    source_logsys
    
 , 
    cast(null as TEXT) as 
    
    spr_rsn_profile
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 , 
    cast(null as TEXT) as 
    
    stafo
    
 , 
    cast(null as TEXT) as 
    
    stako
    
 , 
    cast(null as TEXT) as 
    
    statu
    
 , 
    cast(null as TEXT) as 
    
    stceg
    
 , 
    cast(null as TEXT) as 
    
    stceg_l
    
 , 
    cast(null as TEXT) as 
    
    submi
    
 , 
    cast(null as TEXT) as 
    
    telf1
    
 , 
    cast(null as TEXT) as 
    
    threshold_exists
    
 , 
    cast(null as TEXT) as 
    
    unsez
    
 , 
    cast(null as TEXT) as 
    
    upinc
    
 , 
    cast(null as TEXT) as 
    
    verkf
    
 , 
    cast(null as TEXT) as 
    
    vsart
    
 , 
    cast(null as TEXT) as 
    
    vzskz
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as TEXT) as 
    
    weakt
    
 , 
    cast(null as TEXT) as 
    
    werks_allow
    
 , 
    cast(null as TEXT) as 
    
    wkurs
    
 , 
    cast(null as TEXT) as 
    
    zbd1p
    
 , 
    cast(null as TEXT) as 
    
    zbd1t
    
 , 
    cast(null as TEXT) as 
    
    zbd2p
    
 , 
    cast(null as TEXT) as 
    
    zbd2t
    
 , 
    cast(null as TEXT) as 
    
    zbd3t
    
 , 
    cast(null as TEXT) as 
    
    zterm
    
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
        abgru,
        absgr,
        addnr,
        adrnr,
        aedat,
        angdt,
        angnr,
        aurel_allow,
        ausnr,
        autlf,
        bedat,
        bnddt,
        bsakz,
        bsart,
        bstyp,
        bwbdt,
        budg_type,
        cast(bukrs as TEXT) as bukrs,
        check_type,
        con_distr_lev,
        con_otb_req,
        con_prebook_lev,
        contract_allow,
        delper_allow,
        description,
        dpamt,
        dpdat,
        dppct,
        dptyp,
        cast(ebeln as TEXT) as ebeln,
        eindt,
        eindt_allow,
        ekgrp,
        ekgrp_allow,
        ekorg,
        eq_eindt,
        eq_werks,
        ernam,
        exnum,
        fixpo,
        fixpo_allow,
        force_cnt,
        force_id,
        frggr,
        frgke,
        frgrl,
        frgsx,
        frgzu,
        fsh_item_group,
        fsh_os_stg_change,
        fsh_snst_status,
        fsh_transaction,
        fsh_vas_last_item,
        gwldt,
        handoverloc,
        hierarchy_exists,
        hvr_change_time,
        hvr_is_deleted,
        ihran,
        ihrez,
        inco1,
        inco2,
        inco2_l,
        inco3_l,
        incov,
        kalsm,
        kdatb,
        kdate,
        key_id,
        key_id_allow,
        knumv,
        konnr,
        kornr,
        ktwrt,
        kufix,
        cast(kunnr as TEXT) as kunnr,
        lands,
        lblif,
        legal_contract,
        lifnr,
        lifre,
        llief,
        loekz,
        logsy,
        lphis,
        lponr,
        ltsnr_allow,
        cast(mandt as TEXT) as mandt,
        memory,
        memorytype,
        msr_id,
        otb_cond_type,
        otb_curr,
        otb_level,
        otb_reason,
        otb_res_value,
        otb_spec_value,
        otb_status,
        otb_value,
        pincr,
        pohf_type,
        procstat,
        pstyp_allow,
        release_date,
        reason_code,
        reloc_id,
        reloc_seq_id,
        reswk,
        retpc,
        rettp,
        revno,
        rlwrt,
        scmproc,
        shipcond,
        source_logsys,
        spr_rsn_profile,
        spras,
        stafo,
        stako,
        statu,
        stceg,
        stceg_l,
        submi,
        telf1,
        threshold_exists,
        unsez,
        upinc,
        verkf,
        vsart,
        vzskz,
        waers,
        weakt,
        werks_allow,
        wkurs,
        zbd1p,
        zbd1t,
        zbd2p,
        zbd2t,
        zbd3t,
        zterm,
        _fivetran_sap_archived,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
