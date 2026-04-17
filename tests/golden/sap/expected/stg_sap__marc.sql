with base as (
    select 
    from "sap"."main_sap"."stg_sap__marc_tmp"
),

fields as (
    select
        
    cast(null as numeric(28,6)) as 
    
    _cwm_bwesb
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_trame
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_umlmc
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as boolean) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as numeric(28,6)) as 
    
    _sapmp_tolprmi
    
 , 
    cast(null as numeric(28,6)) as 
    
    _sapmp_tolprpl
    
 , 
    cast(null as date) as 
    
    _sttpec_servalid
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_fork_dir
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_lane_num
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_pal_vend
    
 , 
    cast(null as TEXT) as 
    
    _vso_r_pkgrp
    
 , 
    cast(null as TEXT) as 
    
    abcin
    
 , 
    cast(null as numeric(28,6)) as 
    
    abfac
    
 , 
    cast(null as TEXT) as 
    
    ahdis
    
 , 
    cast(null as TEXT) as 
    
    altsl
    
 , 
    cast(null as TEXT) as 
    
    aplal
    
 , 
    cast(null as TEXT) as 
    
    apokz
    
 , 
    cast(null as TEXT) as 
    
    arun_fix_batch
    
 , 
    cast(null as TEXT) as 
    
    atpkz
    
 , 
    cast(null as TEXT) as 
    
    auftl
    
 , 
    cast(null as date) as 
    
    ausdt
    
 , 
    cast(null as TEXT) as 
    
    ausme
    
 , 
    cast(null as numeric(28,6)) as 
    
    ausss
    
 , 
    cast(null as TEXT) as 
    
    autru
    
 , 
    cast(null as TEXT) as 
    
    awsls
    
 , 
    cast(null as numeric(28,6)) as 
    
    basmg
    
 , 
    cast(null as numeric(28,6)) as 
    
    bearz
    
 , 
    cast(null as TEXT) as 
    
    beskz
    
 , 
    cast(null as numeric(28,6)) as 
    
    bstfe
    
 , 
    cast(null as numeric(28,6)) as 
    
    bstma
    
 , 
    cast(null as numeric(28,6)) as 
    
    bstmi
    
 , 
    cast(null as numeric(28,6)) as 
    
    bstrf
    
 , 
    cast(null as numeric(28,6)) as 
    
    bwesb
    
 , 
    cast(null as TEXT) as 
    
    bwscl
    
 , 
    cast(null as TEXT) as 
    
    bwtty
    
 , 
    cast(null as TEXT) as 
    
    casnr
    
 , 
    cast(null as TEXT) as 
    
    ccfix
    
 , 
    cast(null as TEXT) as 
    
    compl
    
 , 
    cast(null as TEXT) as 
    
    conf_gmsync
    
 , 
    cast(null as TEXT) as 
    
    cons_procg
    
 , 
    cast(null as TEXT) as 
    
    convt
    
 , 
    cast(null as TEXT) as 
    
    copam
    
 , 
    cast(null as TEXT) as 
    
    cuobj
    
 , 
    cast(null as TEXT) as 
    
    cuobv
    
 , 
    cast(null as TEXT) as 
    
    diber
    
 , 
    cast(null as TEXT) as 
    
    disgr
    
 , 
    cast(null as TEXT) as 
    
    disls
    
 , 
    cast(null as TEXT) as 
    
    dismm
    
 , 
    cast(null as TEXT) as 
    
    dispo
    
 , 
    cast(null as TEXT) as 
    
    dispr
    
 , 
    cast(null as TEXT) as 
    
    dpcbt
    
 , 
    cast(null as TEXT) as 
    
    dplfs
    
 , 
    cast(null as numeric(28,6)) as 
    
    dplho
    
 , 
    cast(null as TEXT) as 
    
    dplpu
    
 , 
    cast(null as TEXT) as 
    
    dummy_plnt_incl_eew_ps
    
 , 
    cast(null as numeric(28,6)) as 
    
    dzeit
    
 , 
    cast(null as numeric(28,6)) as 
    
    eisbe
    
 , 
    cast(null as numeric(28,6)) as 
    
    eislo
    
 , 
    cast(null as TEXT) as 
    
    ekgrp
    
 , 
    cast(null as TEXT) as 
    
    eprio
    
 , 
    cast(null as TEXT) as 
    
    esppflg
    
 , 
    cast(null as TEXT) as 
    
    excise_tax_rlvnce
    
 , 
    cast(null as TEXT) as 
    
    expme
    
 , 
    cast(null as TEXT) as 
    
    fabkz
    
 , 
    cast(null as TEXT) as 
    
    fevor
    
 , 
    cast(null as TEXT) as 
    
    ffrei
    
 , 
    cast(null as TEXT) as 
    
    fhori
    
 , 
    cast(null as numeric(28,6)) as 
    
    fixls
    
 , 
    cast(null as TEXT) as 
    
    fprfm
    
 , 
    cast(null as TEXT) as 
    
    frtme
    
 , 
    cast(null as TEXT) as 
    
    fsh_calendar_group
    
 , 
    cast(null as TEXT) as 
    
    fsh_kzech
    
 , 
    cast(null as TEXT) as 
    
    fsh_mg_arun_req
    
 , 
    cast(null as TEXT) as 
    
    fsh_seaim
    
 , 
    cast(null as TEXT) as 
    
    fsh_var_group
    
 , 
    cast(null as TEXT) as 
    
    fvidk
    
 , 
    cast(null as TEXT) as 
    
    fxhor
    
 , 
    cast(null as TEXT) as 
    
    fxpru
    
 , 
    cast(null as numeric(28,6)) as 
    
    gi_pr_time
    
 , 
    cast(null as numeric(28,6)) as 
    
    glgmg
    
 , 
    cast(null as TEXT) as 
    
    gpmkz
    
 , 
    cast(null as TEXT) as 
    
    gpnum
    
 , 
    cast(null as TEXT) as 
    
    herbl
    
 , 
    cast(null as TEXT) as 
    
    herkl
    
 , 
    cast(null as TEXT) as 
    
    herkr
    
 , 
    cast(null as TEXT) as 
    
    indus
    
 , 
    cast(null as TEXT) as 
    
    insmk
    
 , 
    cast(null as TEXT) as 
    
    itark
    
 , 
    cast(null as TEXT) as 
    
    iuid_relevant
    
 , 
    cast(null as TEXT) as 
    
    iuid_type
    
 , 
    cast(null as TEXT) as 
    
    jitprodnconfprofile
    
 , 
    cast(null as numeric(28,6)) as 
    
    kausf
    
 , 
    cast(null as TEXT) as 
    
    kautb
    
 , 
    cast(null as TEXT) as 
    
    kordb
    
 , 
    cast(null as TEXT) as 
    
    kzagl
    
 , 
    cast(null as TEXT) as 
    
    kzaus
    
 , 
    cast(null as TEXT) as 
    
    kzbed
    
 , 
    cast(null as TEXT) as 
    
    kzdie
    
 , 
    cast(null as TEXT) as 
    
    kzdkz
    
 , 
    cast(null as TEXT) as 
    
    kzech
    
 , 
    cast(null as TEXT) as 
    
    kzkfk
    
 , 
    cast(null as TEXT) as 
    
    kzkri
    
 , 
    cast(null as TEXT) as 
    
    kzkup
    
 , 
    cast(null as TEXT) as 
    
    kzppv
    
 , 
    cast(null as TEXT) as 
    
    kzpro
    
 , 
    cast(null as TEXT) as 
    
    kzpsp
    
 , 
    cast(null as TEXT) as 
    
    ladgr
    
 , 
    cast(null as TEXT) as 
    
    lagpr
    
 , 
    cast(null as TEXT) as 
    
    lfgja
    
 , 
    cast(null as TEXT) as 
    
    lfmon
    
 , 
    cast(null as TEXT) as 
    
    lfrhy
    
 , 
    cast(null as TEXT) as 
    
    lgfsb
    
 , 
    cast(null as TEXT) as 
    
    lgpro
    
 , 
    cast(null as numeric(28,6)) as 
    
    lgrad
    
 , 
    cast(null as TEXT) as 
    
    lizyk
    
 , 
    cast(null as TEXT) as 
    
    loggr
    
 , 
    cast(null as numeric(28,6)) as 
    
    losfx
    
 , 
    cast(null as numeric(28,6)) as 
    
    losgr
    
 , 
    cast(null as numeric(28,6)) as 
    
    ltinc
    
 , 
    cast(null as TEXT) as 
    
    lvorm
    
 , 
    cast(null as TEXT) as 
    
    lzeih
    
 , 
    cast(null as TEXT) as 
    
    maabc
    
 , 
    cast(null as numeric(28,6)) as 
    
    mabst
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    matgr
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as TEXT) as 
    
    max_troc
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxls
    
 , 
    cast(null as numeric(28,6)) as 
    
    maxlz
    
 , 
    cast(null as TEXT) as 
    
    mcrue
    
 , 
    cast(null as TEXT) as 
    
    mdach
    
 , 
    cast(null as TEXT) as 
    
    megru
    
 , 
    cast(null as TEXT) as 
    
    mfrgr
    
 , 
    cast(null as TEXT) as 
    
    min_troc
    
 , 
    cast(null as numeric(28,6)) as 
    
    minbe
    
 , 
    cast(null as numeric(28,6)) as 
    
    minls
    
 , 
    cast(null as TEXT) as 
    
    miskz
    
 , 
    cast(null as TEXT) as 
    
    mmsta
    
 , 
    cast(null as date) as 
    
    mmstd
    
 , 
    cast(null as TEXT) as 
    
    mogru
    
 , 
    cast(null as TEXT) as 
    
    mownr
    
 , 
    cast(null as numeric(28,6)) as 
    
    mpdau
    
 , 
    cast(null as TEXT) as 
    
    mrppp
    
 , 
    cast(null as TEXT) as 
    
    mtver
    
 , 
    cast(null as TEXT) as 
    
    mtvfp
    
 , 
    cast(null as TEXT) as 
    
    multiple_ekgrp
    
 , 
    cast(null as TEXT) as 
    
    ncost
    
 , 
    cast(null as TEXT) as 
    
    nf_flag
    
 , 
    cast(null as TEXT) as 
    
    nfmat
    
 , 
    cast(null as date) as 
    
    nkmpr
    
 , 
    cast(null as TEXT) as 
    
    objid
    
 , 
    cast(null as TEXT) as 
    
    ocmpf
    
 , 
    cast(null as TEXT) as 
    
    otype
    
 , 
    cast(null as TEXT) as 
    
    periv
    
 , 
    cast(null as TEXT) as 
    
    perkz
    
 , 
    cast(null as TEXT) as 
    
    pfrei
    
 , 
    cast(null as numeric(28,6)) as 
    
    plifz
    
 , 
    cast(null as TEXT) as 
    
    plnnr
    
 , 
    cast(null as TEXT) as 
    
    plnty
    
 , 
    cast(null as TEXT) as 
    
    plvar
    
 , 
    cast(null as TEXT) as 
    
    ppskz
    
 , 
    cast(null as TEXT) as 
    
    prctr
    
 , 
    cast(null as TEXT) as 
    
    prefe
    
 , 
    cast(null as TEXT) as 
    
    prenc
    
 , 
    cast(null as date) as 
    
    prend
    
 , 
    cast(null as TEXT) as 
    
    prene
    
 , 
    cast(null as date) as 
    
    preng
    
 , 
    cast(null as TEXT) as 
    
    preno
    
 , 
    cast(null as numeric(28,6)) as 
    
    prfrq
    
 , 
    cast(null as TEXT) as 
    
    profil
    
 , 
    cast(null as TEXT) as 
    
    pstat
    
 , 
    cast(null as TEXT) as 
    
    qmata
    
 , 
    cast(null as TEXT) as 
    
    qmatv
    
 , 
    cast(null as TEXT) as 
    
    qssys
    
 , 
    cast(null as numeric(28,6)) as 
    
    quazt
    
 , 
    cast(null as TEXT) as 
    
    qzgtp
    
 , 
    cast(null as TEXT) as 
    
    rdprf
    
 , 
    cast(null as TEXT) as 
    
    ref_schema
    
 , 
    cast(null as numeric(28,6)) as 
    
    resvp
    
 , 
    cast(null as TEXT) as 
    
    rgekz
    
 , 
    cast(null as TEXT) as 
    
    rotation_date
    
 , 
    cast(null as numeric(28,6)) as 
    
    ruezt
    
 , 
    cast(null as TEXT) as 
    
    rwpro
    
 , 
    cast(null as TEXT) as 
    
    sauft
    
 , 
    cast(null as TEXT) as 
    
    sbdkz
    
 , 
    cast(null as TEXT) as 
    
    schgt
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_conhap
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_conhap_out
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_coninp
    
 , 
    cast(null as TEXT) as 
    
    scm_fixpeg_prod_set
    
 , 
    cast(null as TEXT) as 
    
    scm_ges_bst_use
    
 , 
    cast(null as TEXT) as 
    
    scm_ges_mng_use
    
 , 
    cast(null as TEXT) as 
    
    scm_get_alerts
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_giprt
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_grprt
    
 , 
    cast(null as TEXT) as 
    
    scm_heur_id
    
 , 
    cast(null as TEXT) as 
    
    scm_hunit
    
 , 
    cast(null as TEXT) as 
    
    scm_hunit_out
    
 , 
    cast(null as TEXT) as 
    
    scm_intsrc_prof
    
 , 
    cast(null as TEXT) as 
    
    scm_iunit
    
 , 
    cast(null as TEXT) as 
    
    scm_lsuom
    
 , 
    cast(null as TEXT) as 
    
    scm_matlocid_guid16
    
 , 
    cast(null as TEXT) as 
    
    scm_matlocid_guid22
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_maturity_dur
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_maxstock_v
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_min_pass_amount
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_ndcostwa
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_ndcostwe
    
 , 
    cast(null as TEXT) as 
    
    scm_package_id
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_peg_future_alert
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_peg_past_alert
    
 , 
    cast(null as TEXT) as 
    
    scm_peg_strategy
    
 , 
    cast(null as TEXT) as 
    
    scm_peg_wo_alert_fst
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_ppsaftystk
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_ppsaftystk_v
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_prio
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_proc_cost
    
 , 
    cast(null as TEXT) as 
    
    scm_profid
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_reldt
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_reord_dur
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_reord_v
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_repsafty
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_repsafty_v
    
 , 
    cast(null as TEXT) as 
    
    scm_res_net_name
    
 , 
    cast(null as TEXT) as 
    
    scm_rrp_sel_group
    
 , 
    cast(null as TEXT) as 
    
    scm_rrp_type
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_safty_v
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_scost
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_scost_prcnt
    
 , 
    cast(null as TEXT) as 
    
    scm_sft_lock
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_shelf_life_dur
    
 , 
    cast(null as TEXT) as 
    
    scm_shelf_life_loc
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_shlf_lfe_req_max
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_shlf_lfe_req_min
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_sspen
    
 , 
    cast(null as TEXT) as 
    
    scm_stra1
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_target_dur
    
 , 
    cast(null as numeric(28,6)) as 
    
    scm_thruput_time
    
 , 
    cast(null as TEXT) as 
    
    scm_tpop
    
 , 
    cast(null as TEXT) as 
    
    scm_tstrid
    
 , 
    cast(null as TEXT) as 
    
    scm_whatbom
    
 , 
    cast(null as TEXT) as 
    
    sernp
    
 , 
    cast(null as TEXT) as 
    
    servg
    
 , 
    cast(null as TEXT) as 
    
    sfcpf
    
 , 
    cast(null as TEXT) as 
    
    sfepr
    
 , 
    cast(null as TEXT) as 
    
    sfty_stk_meth
    
 , 
    cast(null as TEXT) as 
    
    sgt_chint
    
 , 
    cast(null as TEXT) as 
    
    sgt_covs
    
 , 
    cast(null as TEXT) as 
    
    sgt_defsc
    
 , 
    cast(null as date) as 
    
    sgt_mmstd
    
 , 
    cast(null as TEXT) as 
    
    sgt_mrp_atp_status
    
 , 
    cast(null as TEXT) as 
    
    sgt_mrpsi
    
 , 
    cast(null as TEXT) as 
    
    sgt_prcm
    
 , 
    cast(null as TEXT) as 
    
    sgt_scope
    
 , 
    cast(null as TEXT) as 
    
    sgt_statc
    
 , 
    cast(null as TEXT) as 
    
    sgt_stk_prt
    
 , 
    cast(null as TEXT) as 
    
    shflg
    
 , 
    cast(null as TEXT) as 
    
    shpro
    
 , 
    cast(null as TEXT) as 
    
    shzet
    
 , 
    cast(null as TEXT) as 
    
    sobsk
    
 , 
    cast(null as TEXT) as 
    
    sobsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    sproz
    
 , 
    cast(null as TEXT) as 
    
    ssqss
    
 , 
    cast(null as TEXT) as 
    
    stawn
    
 , 
    cast(null as TEXT) as 
    
    stdpd
    
 , 
    cast(null as TEXT) as 
    
    steuc
    
 , 
    cast(null as TEXT) as 
    
    stlal
    
 , 
    cast(null as TEXT) as 
    
    stlan
    
 , 
    cast(null as TEXT) as 
    
    strgr
    
 , 
    cast(null as numeric(28,6)) as 
    
    takzt
    
 , 
    cast(null as numeric(28,6)) as 
    
    target_stock
    
 , 
    cast(null as numeric(28,6)) as 
    
    temp_ctrl_max
    
 , 
    cast(null as numeric(28,6)) as 
    
    temp_ctrl_min
    
 , 
    cast(null as TEXT) as 
    
    temp_uom
    
 , 
    cast(null as numeric(28,6)) as 
    
    trame
    
 , 
    cast(null as numeric(28,6)) as 
    
    tranz
    
 , 
    cast(null as TEXT) as 
    
    uchkz
    
 , 
    cast(null as TEXT) as 
    
    ucmat
    
 , 
    cast(null as TEXT) as 
    
    ueetk
    
 , 
    cast(null as numeric(28,6)) as 
    
    ueeto
    
 , 
    cast(null as TEXT) as 
    
    uid_iea
    
 , 
    cast(null as numeric(28,6)) as 
    
    umlmc
    
 , 
    cast(null as TEXT) as 
    
    umrsl
    
 , 
    cast(null as numeric(28,6)) as 
    
    uneto
    
 , 
    cast(null as TEXT) as 
    
    uomgr
    
 , 
    cast(null as TEXT) as 
    
    usequ
    
 , 
    cast(null as numeric(28,6)) as 
    
    vbamg
    
 , 
    cast(null as numeric(28,6)) as 
    
    vbeaz
    
 , 
    cast(null as TEXT) as 
    
    verkz
    
 , 
    cast(null as TEXT) as 
    
    vint1
    
 , 
    cast(null as TEXT) as 
    
    vint2
    
 , 
    cast(null as numeric(28,6)) as 
    
    vkglg
    
 , 
    cast(null as numeric(28,6)) as 
    
    vktrw
    
 , 
    cast(null as numeric(28,6)) as 
    
    vkumc
    
 , 
    cast(null as date) as 
    
    vrbdt
    
 , 
    cast(null as numeric(28,6)) as 
    
    vrbfk
    
 , 
    cast(null as TEXT) as 
    
    vrbmt
    
 , 
    cast(null as TEXT) as 
    
    vrbwk
    
 , 
    cast(null as TEXT) as 
    
    vrmod
    
 , 
    cast(null as numeric(28,6)) as 
    
    vrvez
    
 , 
    cast(null as TEXT) as 
    
    vspvb
    
 , 
    cast(null as numeric(28,6)) as 
    
    vzusl
    
 , 
    cast(null as numeric(28,6)) as 
    
    webaz
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as numeric(28,6)) as 
    
    wstgh
    
 , 
    cast(null as numeric(28,6)) as 
    
    wzeit
    
 , 
    cast(null as TEXT) as 
    
    xchar
    
 , 
    cast(null as TEXT) as 
    
    xchpf
    
 , 
    cast(null as TEXT) as 
    
    xmcng
    
 


    from base
),

final as (
    select
        _cwm_bwesb,
        _cwm_trame,
        _cwm_umlmc,
        _fivetran_deleted,
        _fivetran_sap_archived,
        _fivetran_synced,
        _sapmp_tolprmi,
        _sapmp_tolprpl,
        _sttpec_servalid,
        _vso_r_fork_dir,
        _vso_r_lane_num,
        _vso_r_pal_vend,
        _vso_r_pkgrp,
        abcin,
        abfac,
        ahdis,
        altsl,
        aplal,
        apokz,
        arun_fix_batch,
        atpkz,
        auftl,
        ausdt,
        ausme,
        ausss,
        autru,
        awsls,
        basmg,
        bearz,
        beskz,
        bstfe,
        bstma,
        bstmi,
        bstrf,
        bwesb,
        bwscl,
        bwtty,
        casnr,
        ccfix,
        compl,
        conf_gmsync,
        cons_procg,
        convt,
        copam,
        cuobj,
        cuobv,
        diber,
        disgr,
        disls,
        dismm,
        dispo,
        dispr,
        dpcbt,
        dplfs,
        dplho,
        dplpu,
        dummy_plnt_incl_eew_ps,
        dzeit,
        eisbe,
        eislo,
        ekgrp,
        eprio,
        esppflg,
        excise_tax_rlvnce,
        expme,
        fabkz,
        fevor,
        ffrei,
        fhori,
        fixls,
        fprfm,
        frtme,
        fsh_calendar_group,
        fsh_kzech,
        fsh_mg_arun_req,
        fsh_seaim,
        fsh_var_group,
        fvidk,
        fxhor,
        fxpru,
        gi_pr_time,
        glgmg,
        gpmkz,
        gpnum,
        herbl,
        herkl,
        herkr,
        indus,
        insmk,
        itark,
        iuid_relevant,
        iuid_type,
        jitprodnconfprofile,
        kausf,
        kautb,
        kordb,
        kzagl,
        kzaus,
        kzbed,
        kzdie,
        kzdkz,
        kzech,
        kzkfk,
        kzkri,
        kzkup,
        kzppv,
        kzpro,
        kzpsp,
        ladgr,
        lagpr,
        cast(lfgja as TEXT) as lfgja,
        cast(lfmon as TEXT) as lfmon,
        lfrhy,
        lgfsb,
        lgpro,
        lgrad,
        lizyk,
        loggr,
        losfx,
        losgr,
        ltinc,
        lvorm,
        lzeih,
        maabc,
        mabst,
        cast(mandt as TEXT) as mandt,
        matgr,
        cast(matnr as TEXT) as matnr,
        max_troc,
        maxls,
        maxlz,
        mcrue,
        mdach,
        megru,
        mfrgr,
        min_troc,
        minbe,
        minls,
        miskz,
        mmsta,
        mmstd,
        mogru,
        mownr,
        mpdau,
        mrppp,
        mtver,
        mtvfp,
        multiple_ekgrp,
        ncost,
        nf_flag,
        nfmat,
        nkmpr,
        objid,
        ocmpf,
        otype,
        periv,
        perkz,
        pfrei,
        plifz,
        plnnr,
        plnty,
        plvar,
        ppskz,
        prctr,
        prefe,
        prenc,
        prend,
        prene,
        preng,
        preno,
        prfrq,
        profil,
        pstat,
        qmata,
        qmatv,
        qssys,
        quazt,
        qzgtp,
        rdprf,
        ref_schema,
        resvp,
        rgekz,
        rotation_date,
        ruezt,
        rwpro,
        sauft,
        sbdkz,
        schgt,
        scm_conhap,
        scm_conhap_out,
        scm_coninp,
        scm_fixpeg_prod_set,
        scm_ges_bst_use,
        scm_ges_mng_use,
        scm_get_alerts,
        scm_giprt,
        scm_grprt,
        scm_heur_id,
        scm_hunit,
        scm_hunit_out,
        scm_intsrc_prof,
        scm_iunit,
        scm_lsuom,
        scm_matlocid_guid16,
        scm_matlocid_guid22,
        scm_maturity_dur,
        scm_maxstock_v,
        scm_min_pass_amount,
        scm_ndcostwa,
        scm_ndcostwe,
        scm_package_id,
        scm_peg_future_alert,
        scm_peg_past_alert,
        scm_peg_strategy,
        scm_peg_wo_alert_fst,
        scm_ppsaftystk,
        scm_ppsaftystk_v,
        scm_prio,
        scm_proc_cost,
        scm_profid,
        scm_reldt,
        scm_reord_dur,
        scm_reord_v,
        scm_repsafty,
        scm_repsafty_v,
        scm_res_net_name,
        scm_rrp_sel_group,
        scm_rrp_type,
        scm_safty_v,
        scm_scost,
        scm_scost_prcnt,
        scm_sft_lock,
        scm_shelf_life_dur,
        scm_shelf_life_loc,
        scm_shlf_lfe_req_max,
        scm_shlf_lfe_req_min,
        scm_sspen,
        scm_stra1,
        scm_target_dur,
        scm_thruput_time,
        scm_tpop,
        scm_tstrid,
        scm_whatbom,
        sernp,
        servg,
        sfcpf,
        sfepr,
        sfty_stk_meth,
        sgt_chint,
        sgt_covs,
        sgt_defsc,
        sgt_mmstd,
        sgt_mrp_atp_status,
        sgt_mrpsi,
        sgt_prcm,
        sgt_scope,
        sgt_statc,
        sgt_stk_prt,
        shflg,
        shpro,
        shzet,
        sobsk,
        sobsl,
        sproz,
        ssqss,
        stawn,
        stdpd,
        steuc,
        stlal,
        stlan,
        strgr,
        takzt,
        target_stock,
        temp_ctrl_max,
        temp_ctrl_min,
        temp_uom,
        trame,
        tranz,
        uchkz,
        ucmat,
        ueetk,
        ueeto,
        uid_iea,
        umlmc,
        umrsl,
        uneto,
        uomgr,
        usequ,
        vbamg,
        vbeaz,
        verkz,
        vint1,
        vint2,
        vkglg,
        vktrw,
        vkumc,
        vrbdt,
        vrbfk,
        vrbmt,
        vrbwk,
        vrmod,
        vrvez,
        vspvb,
        vzusl,
        webaz,
        cast(werks as TEXT) as werks,
        wstgh,
        wzeit,
        xchar,
        xchpf,
        xmcng
    from fields
)

select *
from final
