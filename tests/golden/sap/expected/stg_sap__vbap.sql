with base as (
    select 
    from "sap"."main_sap"."stg_sap__vbap_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    _accgo_is_co_rel
    
 , 
    cast(null as TEXT) as 
    
    _accgo_tx_p
    
 , 
    cast(null as TEXT) as 
    
    _bev1_srfund
    
 , 
    cast(null as TEXT) as 
    
    _dataaging
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    _slce_inst_guid
    
 , 
    cast(null as TEXT) as 
    
    _slce_single_conf_done
    
 , 
    cast(null as TEXT) as 
    
    _slce_single_conf_reqired
    
 , 
    cast(null as TEXT) as 
    
    _slce_sol_cuobj
    
 , 
    cast(null as TEXT) as 
    
    _slce_sol_ext_guid
    
 , 
    cast(null as TEXT) as 
    
    _slce_sol_matnr
    
 , 
    cast(null as TEXT) as 
    
    _slce_sol_posnr
    
 , 
    cast(null as TEXT) as 
    
    _xlso_course_bda
    
 , 
    cast(null as TEXT) as 
    
    _xlso_course_eda
    
 , 
    cast(null as TEXT) as 
    
    _xlso_course_id
    
 , 
    cast(null as TEXT) as 
    
    abdat
    
 , 
    cast(null as TEXT) as 
    
    abfor
    
 , 
    cast(null as TEXT) as 
    
    abges
    
 , 
    cast(null as TEXT) as 
    
    abgrs
    
 , 
    cast(null as TEXT) as 
    
    abgru
    
 , 
    cast(null as TEXT) as 
    
    ablfz
    
 , 
    cast(null as TEXT) as 
    
    absfz
    
 , 
    cast(null as TEXT) as 
    
    aedat
    
 , 
    cast(null as TEXT) as 
    
    antlf
    
 , 
    cast(null as TEXT) as 
    
    anzsn
    
 , 
    cast(null as TEXT) as 
    
    aplzl_oaa
    
 , 
    cast(null as TEXT) as 
    
    aplzl_olc
    
 , 
    cast(null as TEXT) as 
    
    arktx
    
 , 
    cast(null as TEXT) as 
    
    arsnum
    
 , 
    cast(null as TEXT) as 
    
    arspos
    
 , 
    cast(null as TEXT) as 
    
    atpkz
    
 , 
    cast(null as TEXT) as 
    
    aufnr
    
 , 
    cast(null as TEXT) as 
    
    aufpl_oaa
    
 , 
    cast(null as TEXT) as 
    
    aufpl_olc
    
 , 
    cast(null as TEXT) as 
    
    awahr
    
 , 
    cast(null as TEXT) as 
    
    bedae
    
 , 
    cast(null as TEXT) as 
    
    berid
    
 , 
    cast(null as TEXT) as 
    
    betc
    
 , 
    cast(null as TEXT) as 
    
    bonus
    
 , 
    cast(null as TEXT) as 
    
    bpn
    
 , 
    cast(null as TEXT) as 
    
    brgew
    
 , 
    cast(null as TEXT) as 
    
    budget_pd
    
 , 
    cast(null as TEXT) as 
    
    bwtar
    
 , 
    cast(null as TEXT) as 
    
    bwtex
    
 , 
    cast(null as TEXT) as 
    
    cancel_allow
    
 , 
    cast(null as TEXT) as 
    
    cepok
    
 , 
    cast(null as TEXT) as 
    
    charg
    
 , 
    cast(null as TEXT) as 
    
    chmvs
    
 , 
    cast(null as TEXT) as 
    
    chspl
    
 , 
    cast(null as TEXT) as 
    
    clint
    
 , 
    cast(null as TEXT) as 
    
    cmeth
    
 , 
    cast(null as TEXT) as 
    
    cmkua
    
 , 
    cast(null as TEXT) as 
    
    cmpnt
    
 , 
    cast(null as TEXT) as 
    
    cmpre_flt
    
 , 
    cast(null as TEXT) as 
    
    cmpre
    
 , 
    cast(null as TEXT) as 
    
    cmtfg
    
 , 
    cast(null as TEXT) as 
    
    cpd_updat
    
 , 
    cast(null as TEXT) as 
    
    cuobj_ch
    
 , 
    cast(null as TEXT) as 
    
    cuobj
    
 , 
    cast(null as TEXT) as 
    
    ean11
    
 , 
    cast(null as TEXT) as 
    
    eannr
    
 , 
    cast(null as TEXT) as 
    
    erdat
    
 , 
    cast(null as TEXT) as 
    
    erlre
    
 , 
    cast(null as TEXT) as 
    
    ernam
    
 , 
    cast(null as TEXT) as 
    
    erzet
    
 , 
    cast(null as TEXT) as 
    
    exart
    
 , 
    cast(null as TEXT) as 
    
    faksp
    
 , 
    cast(null as TEXT) as 
    
    ferc_ind
    
 , 
    cast(null as TEXT) as 
    
    fiscal_incentive_id
    
 , 
    cast(null as TEXT) as 
    
    fiscal_incentive
    
 , 
    cast(null as TEXT) as 
    
    fistl
    
 , 
    cast(null as TEXT) as 
    
    fixmg
    
 , 
    cast(null as TEXT) as 
    
    fkber
    
 , 
    cast(null as TEXT) as 
    
    fkrel
    
 , 
    cast(null as TEXT) as 
    
    fmeng
    
 , 
    cast(null as TEXT) as 
    
    fmfgus_key
    
 , 
    cast(null as TEXT) as 
    
    fonds
    
 , 
    cast(null as TEXT) as 
    
    fsh_candate
    
 , 
    cast(null as TEXT) as 
    
    fsh_collection
    
 , 
    cast(null as TEXT) as 
    
    fsh_crsd
    
 , 
    cast(null as TEXT) as 
    
    fsh_grid_cond_rec
    
 , 
    cast(null as TEXT) as 
    
    fsh_item_group
    
 , 
    cast(null as TEXT) as 
    
    fsh_item
    
 , 
    cast(null as TEXT) as 
    
    fsh_pqr_uepos
    
 , 
    cast(null as TEXT) as 
    
    fsh_psm_pfm_split
    
 , 
    cast(null as TEXT) as 
    
    fsh_searef
    
 , 
    cast(null as TEXT) as 
    
    fsh_season_year
    
 , 
    cast(null as TEXT) as 
    
    fsh_season
    
 , 
    cast(null as TEXT) as 
    
    fsh_theme
    
 , 
    cast(null as TEXT) as 
    
    fsh_transaction
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_prnt_id
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_rel
    
 , 
    cast(null as TEXT) as 
    
    fsh_vasref
    
 , 
    cast(null as TEXT) as 
    
    gewei
    
 , 
    cast(null as TEXT) as 
    
    grant_nbr
    
 , 
    cast(null as TEXT) as 
    
    grkor
    
 , 
    cast(null as TEXT) as 
    
    grpos
    
 , 
    cast(null as TEXT) as 
    
    gsber
    
 , 
    cast(null as TEXT) as 
    
    handoverdate
    
 , 
    cast(null as TEXT) as 
    
    handoverloc
    
 , 
    cast(null as TEXT) as 
    
    handovertime
    
 , 
    cast(null as TEXT) as 
    
    iuid_relevant
    
 , 
    cast(null as TEXT) as 
    
    j_1bcfop
    
 , 
    cast(null as TEXT) as 
    
    j_1btaxlw1
    
 , 
    cast(null as TEXT) as 
    
    j_1btaxlw2
    
 , 
    cast(null as TEXT) as 
    
    j_1btaxlw3
    
 , 
    cast(null as TEXT) as 
    
    j_1btaxlw4
    
 , 
    cast(null as TEXT) as 
    
    j_1btaxlw5
    
 , 
    cast(null as TEXT) as 
    
    j_1btxsdc
    
 , 
    cast(null as TEXT) as 
    
    kalnr
    
 , 
    cast(null as TEXT) as 
    
    kalsm_k
    
 , 
    cast(null as TEXT) as 
    
    kalvar
    
 , 
    cast(null as TEXT) as 
    
    kannr
    
 , 
    cast(null as TEXT) as 
    
    kbmeng
    
 , 
    cast(null as TEXT) as 
    
    kbver
    
 , 
    cast(null as TEXT) as 
    
    kdmat
    
 , 
    cast(null as TEXT) as 
    
    kever
    
 , 
    cast(null as TEXT) as 
    
    klmeng
    
 , 
    cast(null as TEXT) as 
    
    klvar
    
 , 
    cast(null as TEXT) as 
    
    kmein
    
 , 
    cast(null as TEXT) as 
    
    kmpmg
    
 , 
    cast(null as TEXT) as 
    
    knttp
    
 , 
    cast(null as TEXT) as 
    
    knuma_ag
    
 , 
    cast(null as TEXT) as 
    
    knuma_pi
    
 , 
    cast(null as TEXT) as 
    
    knumh
    
 , 
    cast(null as TEXT) as 
    
    kondm
    
 , 
    cast(null as TEXT) as 
    
    kosch
    
 , 
    cast(null as TEXT) as 
    
    kostl
    
 , 
    cast(null as TEXT) as 
    
    koupd
    
 , 
    cast(null as TEXT) as 
    
    kowrr
    
 , 
    cast(null as TEXT) as 
    
    kpein
    
 , 
    cast(null as TEXT) as 
    
    ktgrm
    
 , 
    cast(null as integer) as 
    
    kwmeng
    
 , 
    cast(null as TEXT) as 
    
    kzbws
    
 , 
    cast(null as TEXT) as 
    
    kzfme
    
 , 
    cast(null as TEXT) as 
    
    kztlf
    
 , 
    cast(null as TEXT) as 
    
    kzvbr
    
 , 
    cast(null as TEXT) as 
    
    kzwi1
    
 , 
    cast(null as TEXT) as 
    
    kzwi2
    
 , 
    cast(null as TEXT) as 
    
    kzwi3
    
 , 
    cast(null as TEXT) as 
    
    kzwi4
    
 , 
    cast(null as TEXT) as 
    
    kzwi5
    
 , 
    cast(null as TEXT) as 
    
    kzwi6
    
 , 
    cast(null as TEXT) as 
    
    lfmng
    
 , 
    cast(null as TEXT) as 
    
    lfrel
    
 , 
    cast(null as TEXT) as 
    
    lgort
    
 , 
    cast(null as TEXT) as 
    
    logsys_ext
    
 , 
    cast(null as TEXT) as 
    
    lprio
    
 , 
    cast(null as TEXT) as 
    
    lsmeng
    
 , 
    cast(null as TEXT) as 
    
    lstanr
    
 , 
    cast(null as TEXT) as 
    
    magrv
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    manual_tc_reason
    
 , 
    cast(null as TEXT) as 
    
    matkl
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as TEXT) as 
    
    matwa
    
 , 
    cast(null as TEXT) as 
    
    meins
    
 , 
    cast(null as TEXT) as 
    
    mfrgr
    
 , 
    cast(null as TEXT) as 
    
    mill_se_gposn
    
 , 
    cast(null as TEXT) as 
    
    mod_allow
    
 , 
    cast(null as TEXT) as 
    
    mprok
    
 , 
    cast(null as TEXT) as 
    
    msr_approv_block
    
 , 
    cast(null as TEXT) as 
    
    msr_refund_code
    
 , 
    cast(null as TEXT) as 
    
    msr_ret_reason
    
 , 
    cast(null as TEXT) as 
    
    mtvfp
    
 , 
    cast(null as TEXT) as 
    
    mvgr1
    
 , 
    cast(null as TEXT) as 
    
    mvgr2
    
 , 
    cast(null as TEXT) as 
    
    mvgr3
    
 , 
    cast(null as TEXT) as 
    
    mvgr4
    
 , 
    cast(null as TEXT) as 
    
    mvgr5
    
 , 
    cast(null as TEXT) as 
    
    mwsbp
    
 , 
    cast(null as TEXT) as 
    
    nachl
    
 , 
    cast(null as TEXT) as 
    
    netpr
    
 , 
    cast(null as integer) as 
    
    netwr
    
 , 
    cast(null as TEXT) as 
    
    nrab_knumh
    
 , 
    cast(null as TEXT) as 
    
    ntgew
    
 , 
    cast(null as TEXT) as 
    
    objnr
    
 , 
    cast(null as TEXT) as 
    
    oia_baselo
    
 , 
    cast(null as TEXT) as 
    
    oibasprod
    
 , 
    cast(null as TEXT) as 
    
    oibwtar_ex
    
 , 
    cast(null as TEXT) as 
    
    oibwtar_im
    
 , 
    cast(null as TEXT) as 
    
    oibypass
    
 , 
    cast(null as TEXT) as 
    
    oic_adestn
    
 , 
    cast(null as TEXT) as 
    
    oic_aorgin
    
 , 
    cast(null as TEXT) as 
    
    oic_dcityc
    
 , 
    cast(null as TEXT) as 
    
    oic_dcounc
    
 , 
    cast(null as TEXT) as 
    
    oic_dland1
    
 , 
    cast(null as TEXT) as 
    
    oic_drcreg
    
 , 
    cast(null as TEXT) as 
    
    oic_drctry
    
 , 
    cast(null as TEXT) as 
    
    oic_dregio
    
 , 
    cast(null as TEXT) as 
    
    oic_kmpos
    
 , 
    cast(null as TEXT) as 
    
    oic_lifnr
    
 , 
    cast(null as TEXT) as 
    
    oic_mot
    
 , 
    cast(null as TEXT) as 
    
    oic_ocityc
    
 , 
    cast(null as TEXT) as 
    
    oic_ocounc
    
 , 
    cast(null as TEXT) as 
    
    oic_oland1
    
 , 
    cast(null as TEXT) as 
    
    oic_oregio
    
 , 
    cast(null as TEXT) as 
    
    oic_pbatch
    
 , 
    cast(null as TEXT) as 
    
    oic_pdestn
    
 , 
    cast(null as TEXT) as 
    
    oic_porgin
    
 , 
    cast(null as TEXT) as 
    
    oic_ptrip
    
 , 
    cast(null as TEXT) as 
    
    oic_truckn
    
 , 
    cast(null as TEXT) as 
    
    oicertf1_ex
    
 , 
    cast(null as TEXT) as 
    
    oicertf1
    
 , 
    cast(null as TEXT) as 
    
    oicontnr
    
 , 
    cast(null as TEXT) as 
    
    oid_extbol
    
 , 
    cast(null as TEXT) as 
    
    oid_miscdl
    
 , 
    cast(null as TEXT) as 
    
    oid_ship
    
 , 
    cast(null as TEXT) as 
    
    oidmsg_dat
    
 , 
    cast(null as TEXT) as 
    
    oidmsg_prd
    
 , 
    cast(null as TEXT) as 
    
    oidmsg_qty
    
 , 
    cast(null as TEXT) as 
    
    oidmsg_shp
    
 , 
    cast(null as TEXT) as 
    
    oidmsg_trm
    
 , 
    cast(null as TEXT) as 
    
    oidmsg_uom
    
 , 
    cast(null as TEXT) as 
    
    oidrc
    
 , 
    cast(null as TEXT) as 
    
    oiedbal_ex
    
 , 
    cast(null as TEXT) as 
    
    oiedbal_im
    
 , 
    cast(null as TEXT) as 
    
    oiedbal
    
 , 
    cast(null as TEXT) as 
    
    oiedbalm_ex
    
 , 
    cast(null as TEXT) as 
    
    oiedbalm_im
    
 , 
    cast(null as TEXT) as 
    
    oiedbalm
    
 , 
    cast(null as TEXT) as 
    
    oiedok
    
 , 
    cast(null as TEXT) as 
    
    oiexgnum
    
 , 
    cast(null as TEXT) as 
    
    oiexgtyp
    
 , 
    cast(null as TEXT) as 
    
    oifeech
    
 , 
    cast(null as TEXT) as 
    
    oifeedt
    
 , 
    cast(null as TEXT) as 
    
    oifeetot
    
 , 
    cast(null as TEXT) as 
    
    oignrule
    
 , 
    cast(null as TEXT) as 
    
    oih_folqty_ex
    
 , 
    cast(null as TEXT) as 
    
    oih_folqty
    
 , 
    cast(null as TEXT) as 
    
    oih_lcfol_ex
    
 , 
    cast(null as TEXT) as 
    
    oih_lcfol
    
 , 
    cast(null as TEXT) as 
    
    oih_licin_ex
    
 , 
    cast(null as TEXT) as 
    
    oih_licin
    
 , 
    cast(null as TEXT) as 
    
    oih_lictp_ex
    
 , 
    cast(null as TEXT) as 
    
    oih_lictp
    
 , 
    cast(null as TEXT) as 
    
    oihantyp_ex
    
 , 
    cast(null as TEXT) as 
    
    oihantyp_im
    
 , 
    cast(null as TEXT) as 
    
    oihantyp
    
 , 
    cast(null as TEXT) as 
    
    oihcotdisch
    
 , 
    cast(null as TEXT) as 
    
    oihnotlgort
    
 , 
    cast(null as TEXT) as 
    
    oihnotwerks
    
 , 
    cast(null as TEXT) as 
    
    oihtaxrcp_ex
    
 , 
    cast(null as TEXT) as 
    
    oiinex_ex
    
 , 
    cast(null as TEXT) as 
    
    oiinex
    
 , 
    cast(null as TEXT) as 
    
    oimetind
    
 , 
    cast(null as TEXT) as 
    
    oinetcyc
    
 , 
    cast(null as TEXT) as 
    
    oioilcon
    
 , 
    cast(null as TEXT) as 
    
    oipipeval
    
 , 
    cast(null as TEXT) as 
    
    oiplantd
    
 , 
    cast(null as TEXT) as 
    
    oipricie_ex
    
 , 
    cast(null as TEXT) as 
    
    oipricie_im
    
 , 
    cast(null as TEXT) as 
    
    oipricie
    
 , 
    cast(null as TEXT) as 
    
    oipsdrc
    
 , 
    cast(null as TEXT) as 
    
    oisbrel
    
 , 
    cast(null as TEXT) as 
    
    oislf
    
 , 
    cast(null as TEXT) as 
    
    oitaxfrom_ex
    
 , 
    cast(null as TEXT) as 
    
    oitaxfrom_im
    
 , 
    cast(null as TEXT) as 
    
    oitaxfrom
    
 , 
    cast(null as TEXT) as 
    
    oitaxgrp_ex
    
 , 
    cast(null as TEXT) as 
    
    oitaxgrp_im
    
 , 
    cast(null as TEXT) as 
    
    oitaxgrp
    
 , 
    cast(null as TEXT) as 
    
    oitaxto_ex
    
 , 
    cast(null as TEXT) as 
    
    oitaxto_im
    
 , 
    cast(null as TEXT) as 
    
    oitaxto
    
 , 
    cast(null as TEXT) as 
    
    oiwap
    
 , 
    cast(null as TEXT) as 
    
    paobjnr
    
 , 
    cast(null as TEXT) as 
    
    pargb
    
 , 
    cast(null as TEXT) as 
    
    pay_method
    
 , 
    cast(null as TEXT) as 
    
    pctrf
    
 , 
    cast(null as TEXT) as 
    
    plavo
    
 , 
    cast(null as TEXT) as 
    
    pmatn
    
 , 
    cast(null as TEXT) as 
    
    posar
    
 , 
    cast(null as TEXT) as 
    
    posex
    
 , 
    cast(null as TEXT) as 
    
    posnr
    
 , 
    cast(null as TEXT) as 
    
    posnv
    
 , 
    cast(null as TEXT) as 
    
    prbme
    
 , 
    cast(null as TEXT) as 
    
    prctr
    
 , 
    cast(null as TEXT) as 
    
    prefe
    
 , 
    cast(null as TEXT) as 
    
    prodh
    
 , 
    cast(null as TEXT) as 
    
    prosa
    
 , 
    cast(null as TEXT) as 
    
    provg
    
 , 
    cast(null as TEXT) as 
    
    prs_objnr
    
 , 
    cast(null as TEXT) as 
    
    prs_sd_spsnr
    
 , 
    cast(null as TEXT) as 
    
    prs_work_period
    
 , 
    cast(null as TEXT) as 
    
    prsok
    
 , 
    cast(null as TEXT) as 
    
    ps_psp_pnr
    
 , 
    cast(null as TEXT) as 
    
    pstyv
    
 , 
    cast(null as TEXT) as 
    
    rep_freq
    
 , 
    cast(null as TEXT) as 
    
    revacc_refid
    
 , 
    cast(null as TEXT) as 
    
    revacc_reftype
    
 , 
    cast(null as TEXT) as 
    
    rkfkf
    
 , 
    cast(null as TEXT) as 
    
    route
    
 , 
    cast(null as TEXT) as 
    
    serail
    
 , 
    cast(null as TEXT) as 
    
    sernr
    
 , 
    cast(null as TEXT) as 
    
    sgt_rcat
    
 , 
    cast(null as TEXT) as 
    
    shkzg
    
 , 
    cast(null as TEXT) as 
    
    skopf
    
 , 
    cast(null as TEXT) as 
    
    sktof
    
 , 
    cast(null as TEXT) as 
    
    sloctype
    
 , 
    cast(null as TEXT) as 
    
    smeng
    
 , 
    cast(null as TEXT) as 
    
    sobkz
    
 , 
    cast(null as TEXT) as 
    
    spart
    
 , 
    cast(null as TEXT) as 
    
    spcsto
    
 , 
    cast(null as TEXT) as 
    
    sposn
    
 , 
    cast(null as TEXT) as 
    
    stadat
    
 , 
    cast(null as TEXT) as 
    
    stafo
    
 , 
    cast(null as TEXT) as 
    
    stcur
    
 , 
    cast(null as TEXT) as 
    
    stdat
    
 , 
    cast(null as TEXT) as 
    
    stkey
    
 , 
    cast(null as TEXT) as 
    
    stlkn
    
 , 
    cast(null as TEXT) as 
    
    stlnr
    
 , 
    cast(null as TEXT) as 
    
    stlty
    
 , 
    cast(null as TEXT) as 
    
    stman
    
 , 
    cast(null as TEXT) as 
    
    stockloc
    
 , 
    cast(null as TEXT) as 
    
    stpos
    
 , 
    cast(null as TEXT) as 
    
    stpoz
    
 , 
    cast(null as TEXT) as 
    
    sugrd
    
 , 
    cast(null as TEXT) as 
    
    sumbd
    
 , 
    cast(null as TEXT) as 
    
    tas
    
 , 
    cast(null as TEXT) as 
    
    tax_subject_st
    
 , 
    cast(null as TEXT) as 
    
    taxm1
    
 , 
    cast(null as TEXT) as 
    
    taxm2
    
 , 
    cast(null as TEXT) as 
    
    taxm3
    
 , 
    cast(null as TEXT) as 
    
    taxm4
    
 , 
    cast(null as TEXT) as 
    
    taxm5
    
 , 
    cast(null as TEXT) as 
    
    taxm6
    
 , 
    cast(null as TEXT) as 
    
    taxm7
    
 , 
    cast(null as TEXT) as 
    
    taxm8
    
 , 
    cast(null as TEXT) as 
    
    taxm9
    
 , 
    cast(null as TEXT) as 
    
    tc_aut_det
    
 , 
    cast(null as TEXT) as 
    
    techs
    
 , 
    cast(null as TEXT) as 
    
    trmrisk_relevant
    
 , 
    cast(null as TEXT) as 
    
    uebtk
    
 , 
    cast(null as TEXT) as 
    
    uebto
    
 , 
    cast(null as TEXT) as 
    
    uepos
    
 , 
    cast(null as TEXT) as 
    
    uepvw
    
 , 
    cast(null as TEXT) as 
    
    ukonm
    
 , 
    cast(null as TEXT) as 
    
    umref
    
 , 
    cast(null as TEXT) as 
    
    umvkn
    
 , 
    cast(null as TEXT) as 
    
    umvkz
    
 , 
    cast(null as TEXT) as 
    
    umzin
    
 , 
    cast(null as TEXT) as 
    
    umziz
    
 , 
    cast(null as TEXT) as 
    
    untto
    
 , 
    cast(null as TEXT) as 
    
    upflu
    
 , 
    cast(null as TEXT) as 
    
    upmat
    
 , 
    cast(null as TEXT) as 
    
    vbeaf
    
 , 
    cast(null as TEXT) as 
    
    vbeav
    
 , 
    cast(null as TEXT) as 
    
    vbeln
    
 , 
    cast(null as TEXT) as 
    
    vbelv
    
 , 
    cast(null as TEXT) as 
    
    vgbel
    
 , 
    cast(null as TEXT) as 
    
    vgpos
    
 , 
    cast(null as TEXT) as 
    
    vgref
    
 , 
    cast(null as TEXT) as 
    
    vgtyp
    
 , 
    cast(null as TEXT) as 
    
    vkaus
    
 , 
    cast(null as TEXT) as 
    
    vkgru
    
 , 
    cast(null as TEXT) as 
    
    voleh
    
 , 
    cast(null as TEXT) as 
    
    volum
    
 , 
    cast(null as TEXT) as 
    
    voref
    
 , 
    cast(null as TEXT) as 
    
    vpmat
    
 , 
    cast(null as TEXT) as 
    
    vpwrk
    
 , 
    cast(null as TEXT) as 
    
    vpzuo
    
 , 
    cast(null as TEXT) as 
    
    vrkme
    
 , 
    cast(null as TEXT) as 
    
    vstel
    
 , 
    cast(null as TEXT) as 
    
    waerk
    
 , 
    cast(null as TEXT) as 
    
    wavwr
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    wgru1
    
 , 
    cast(null as TEXT) as 
    
    wgru2
    
 , 
    cast(null as TEXT) as 
    
    wktnr
    
 , 
    cast(null as TEXT) as 
    
    wktps
    
 , 
    cast(null as TEXT) as 
    
    wrf_charstc1
    
 , 
    cast(null as TEXT) as 
    
    wrf_charstc2
    
 , 
    cast(null as TEXT) as 
    
    wrf_charstc3
    
 , 
    cast(null as TEXT) as 
    
    wtysc_clmitem
    
 , 
    cast(null as TEXT) as 
    
    xchar
    
 , 
    cast(null as TEXT) as 
    
    xchpf
    
 , 
    cast(null as TEXT) as 
    
    z_prs_bill_flag
    
 , 
    cast(null as TEXT) as 
    
    z_prs_chargelevl
    
 , 
    cast(null as TEXT) as 
    
    z_prs_country
    
 , 
    cast(null as TEXT) as 
    
    z_prs_offshore
    
 , 
    cast(null as TEXT) as 
    
    zieme
    
 , 
    cast(null as TEXT) as 
    
    zmeng
    
 , 
    cast(null as TEXT) as 
    
    zschl_k
    
 , 
    cast(null as TEXT) as 
    
    zwert
    
 , 
    cast(null as TEXT) as 
    
    zzdea_license
    
 , 
    cast(null as TEXT) as 
    
    zzdea_schedule
    
 


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
        smeng,
        stlty,
        vgref,
        bwtar,
        knuma_ag,
        spart,
        bwtex,
        oih_licin,
        oic_dcounc,
        knuma_pi,
        oic_dcityc,
        tas,
        oignrule,
        upmat,
        kalsm_k,
        oicertf1_ex,
        aplzl_olc,
        umvkn,
        oidmsg_qty,
        kever,
        mtvfp,
        oihantyp_ex,
        abgru,
        xchar,
        kostl,
        _accgo_tx_p,
        prs_work_period,
        vkgru,
        wktnr,
        absfz,
        oih_lcfol,
        vbeaf,
        ernam,
        oitaxfrom_im,
        stafo,
        oic_lifnr,
        j_1btxsdc,
        taxm1,
        lprio,
        oiedbalm_ex,
        umziz,
        kzvbr,
        oic_aorgin,
        _slce_inst_guid,
        charg,
        stlkn,
        fsh_collection,
        cmeth,
        aplzl_oaa,
        oidmsg_dat,
        umvkz,
        oitaxgrp_ex,
        fsh_candate,
        oipricie_im,
        _slce_sol_posnr,
        tax_subject_st,
        gewei,
        revacc_refid,
        oic_porgin,
        sobkz,
        vpwrk,
        waerk,
        mod_allow,
        umzin,
        magrv,
        oic_pbatch,
        bonus,
        sloctype,
        oiedbal_im,
        fsh_vas_prnt_id,
        ablfz,
        taxm3,
        pstyv,
        _xlso_course_eda,
        fiscal_incentive,
        oic_mot,
        oic_oregio,
        fistl,
        vpmat,
        awahr,
        kpein,
        voleh,
        werks,
        oicertf1,
        knumh,
        taxm2,
        fsh_psm_pfm_split,
        tc_aut_det,
        serail,
        kosch,
        oid_miscdl,
        oih_lictp_ex,
        paobjnr,
        ps_psp_pnr,
        rkfkf,
        sktof,
        fkrel,
        oihantyp,
        _slce_sol_matnr,
        oiplantd,
        lstanr,
        _dataaging,
        cpd_updat,
        oic_drcreg,
        bedae,
        manual_tc_reason,
        spcsto,
        aedat,
        z_prs_offshore,
        kzwi1,
        oiedok,
        fsh_pqr_uepos,
        handovertime,
        xchpf,
        oibwtar_im,
        cast(shkzg as TEXT) as shkzg,
        _slce_sol_cuobj,
        aufpl_olc,
        ntgew,
        vgtyp,
        stockloc,
        pmatn,
        sernr,
        taxm4,
        kalnr,
        oiexgnum,
        erlre,
        oiexgtyp,
        oitaxto_im,
        kzbws,
        _accgo_is_co_rel,
        pargb,
        oimetind,
        oih_folqty,
        oic_truckn,
        uebtk,
        arsnum,
        kdmat,
        bpn,
        mvgr1,
        voref,
        erzet,
        arktx,
        cmpnt,
        oihnotlgort,
        uepos,
        stdat,
        stcur,
        oitaxfrom_ex,
        fiscal_incentive_id,
        _slce_single_conf_done,
        klmeng,
        zmeng,
        oidrc,
        pay_method,
        _slce_sol_ext_guid,
        kzwi2,
        oibypass,
        fsh_item_group,
        aufpl_oaa,
        cast(kwmeng as numeric(28,6)) as kwmeng,
        oih_lcfol_ex,
        koupd,
        fsh_grid_cond_rec,
        techs,
        cast(matnr as TEXT) as matnr,
        wgru1,
        oitaxfrom,
        taxm5,
        kztlf,
        iuid_relevant,
        oic_kmpos,
        z_prs_country,
        gsber,
        oipricie_ex,
        fsh_crsd,
        fsh_transaction,
        grkor,
        uepvw,
        mfrgr,
        vbelv,
        untto,
        plavo,
        vpzuo,
        mvgr3,
        sugrd,
        oic_ptrip,
        oic_adestn,
        oic_oland1,
        mvgr2,
        netpr,
        oicontnr,
        stman,
        oiedbal_ex,
        j_1btaxlw3,
        _slce_single_conf_reqired,
        oinetcyc,
        prsok,
        vgpos,
        cuobj_ch,
        oic_pdestn,
        rep_freq,
        lsmeng,
        stpoz,
        kzwi3,
        posar,
        budget_pd,
        z_prs_chargelevl,
        posnv,
        wgru2,
        oifeetot,
        oic_dregio,
        oih_licin_ex,
        oioilcon,
        aufnr,
        sgt_rcat,
        oidmsg_uom,
        oibasprod,
        msr_refund_code,
        cuobj,
        kbver,
        sposn,
        fsh_season_year,
        zzdea_license,
        taxm6,
        mprok,
        provg,
        oitaxto,
        cmkua,
        cmtfg,
        oid_extbol,
        ukonm,
        mvgr4,
        kmein,
        klvar,
        prs_sd_spsnr,
        mwsbp,
        revacc_reftype,
        wrf_charstc1,
        fsh_item,
        skopf,
        oibwtar_ex,
        prodh,
        stkey,
        j_1btaxlw4,
        route,
        _xlso_course_bda,
        matkl,
        oic_drctry,
        kalvar,
        lfrel,
        kmpmg,
        kzwi4,
        wtysc_clmitem,
        fmeng,
        nrab_knumh,
        oitaxto_ex,
        cmpre,
        handoverdate,
        nachl,
        abdat,
        kondm,
        oic_dland1,
        cmpre_flt,
        taxm7,
        ferc_ind,
        oifeech,
        oih_folqty_ex,
        prctr,
        eannr,
        zschl_k,
        oislf,
        pctrf,
        fsh_vas_rel,
        mvgr5,
        fkber,
        vbeav,
        zwert,
        antlf,
        cancel_allow,
        fsh_searef,
        oipricie,
        wrf_charstc2,
        upflu,
        oihcotdisch,
        oidmsg_shp,
        grant_nbr,
        oidmsg_trm,
        umref,
        kzwi6,
        knttp,
        j_1btaxlw5,
        stlnr,
        vkaus,
        erdat,
        kzwi5,
        fsh_theme,
        fsh_season,
        zieme,
        oipsdrc,
        uebto,
        grpos,
        chmvs,
        oihantyp_im,
        abges,
        oihnotwerks,
        z_prs_bill_flag,
        abgrs,
        taxm8,
        objnr,
        volum,
        oiinex_ex,
        j_1btaxlw1,
        j_1bcfop,
        kowrr,
        fixmg,
        _xlso_course_id,
        fmfgus_key,
        atpkz,
        oifeedt,
        meins,
        oiinex,
        msr_ret_reason,
        handoverloc,
        lfmng,
        ktgrm,
        oia_baselo,
        betc,
        wrf_charstc3,
        oiedbalm_im,
        oihtaxrcp_ex,
        oic_ocounc,
        exart,
        fsh_vasref,
        oiwap,
        vgbel,
        kannr,
        sumbd,
        oidmsg_prd,
        posex,
        oitaxgrp_im,
        oic_ocityc,
        oid_ship,
        prosa,
        berid,
        logsys_ext,
        oipipeval,
        oitaxgrp,
        vrkme,
        ean11,
        taxm9,
        kzfme,
        wktps,
        j_1btaxlw2,
        oiedbalm,
        stpos,
        anzsn,
        oisbrel,
        oih_lictp,
        wavwr,
        arspos,
        _bev1_srfund,
        cast(netwr as numeric(28,6)) as netwr,
        prs_objnr,
        kbmeng,
        prefe,
        prbme,
        clint,
        zzdea_schedule,
        oiedbal,
        trmrisk_relevant,
        chspl,
        matwa,
        faksp,
        fonds,
        brgew,
        abfor,
        stadat,
        vstel,
        mill_se_gposn,
        lgort,
        msr_approv_block,
        cepok
    from fields
)

select *
from final
