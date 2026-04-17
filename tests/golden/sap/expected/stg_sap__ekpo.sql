with base as (
    select 
    from "sap"."main_sap"."stg_sap__ekpo_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    abdat
    
 , 
    cast(null as TEXT) as 
    
    abeln
    
 , 
    cast(null as TEXT) as 
    
    abelp
    
 , 
    cast(null as numeric(28,6)) as 
    
    abftz
    
 , 
    cast(null as numeric(28,6)) as 
    
    abmng
    
 , 
    cast(null as TEXT) as 
    
    abskz
    
 , 
    cast(null as TEXT) as 
    
    abueb
    
 , 
    cast(null as TEXT) as 
    
    adrn2
    
 , 
    cast(null as TEXT) as 
    
    adrnr
    
 , 
    cast(null as TEXT) as 
    
    advcode
    
 , 
    cast(null as TEXT) as 
    
    aedat
    
 , 
    cast(null as TEXT) as 
    
    afnam
    
 , 
    cast(null as TEXT) as 
    
    agdat
    
 , 
    cast(null as TEXT) as 
    
    agmem
    
 , 
    cast(null as TEXT) as 
    
    aktnr
    
 , 
    cast(null as TEXT) as 
    
    anfnr
    
 , 
    cast(null as TEXT) as 
    
    anfps
    
 , 
    cast(null as numeric(28,6)) as 
    
    anzpu
    
 , 
    cast(null as numeric(28,6)) as 
    
    anzsn
    
 , 
    cast(null as TEXT) as 
    
    apoms
    
 , 
    cast(null as TEXT) as 
    
    arsnr
    
 , 
    cast(null as TEXT) as 
    
    arsps
    
 , 
    cast(null as TEXT) as 
    
    attyp
    
 , 
    cast(null as TEXT) as 
    
    aurel
    
 , 
    cast(null as TEXT) as 
    
    banfn
    
 , 
    cast(null as TEXT) as 
    
    bednr
    
 , 
    cast(null as TEXT) as 
    
    berid
    
 , 
    cast(null as TEXT) as 
    
    blk_reason_id
    
 , 
    cast(null as TEXT) as 
    
    blk_reason_txt
    
 , 
    cast(null as TEXT) as 
    
    bnfpo
    
 , 
    cast(null as numeric(28,6)) as 
    
    bonba
    
 , 
    cast(null as TEXT) as 
    
    bonus
    
 , 
    cast(null as TEXT) as 
    
    bprme
    
 , 
    cast(null as numeric(28,6)) as 
    
    bpumn
    
 , 
    cast(null as numeric(28,6)) as 
    
    bpumz
    
 , 
    cast(null as numeric(28,6)) as 
    
    brgew
    
 , 
    cast(null as numeric(28,6)) as 
    
    brtwr
    
 , 
    cast(null as TEXT) as 
    
    bsgru
    
 , 
    cast(null as TEXT) as 
    
    bstae
    
 , 
    cast(null as TEXT) as 
    
    bstyp
    
 , 
    cast(null as TEXT) as 
    
    budget_pd
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    bwtar
    
 , 
    cast(null as TEXT) as 
    
    bwtty
    
 , 
    cast(null as TEXT) as 
    
    ccomp
    
 , 
    cast(null as TEXT) as 
    
    chg_fplnr
    
 , 
    cast(null as TEXT) as 
    
    chg_srv
    
 , 
    cast(null as TEXT) as 
    
    cmpl_dlv_itm
    
 , 
    cast(null as numeric(28,6)) as 
    
    cnfm_qty
    
 , 
    cast(null as TEXT) as 
    
    cons_order
    
 , 
    cast(null as numeric(28,6)) as 
    
    cqu_sar
    
 , 
    cast(null as TEXT) as 
    
    cuobj
    
 , 
    cast(null as TEXT) as 
    
    diff_invoice
    
 , 
    cast(null as TEXT) as 
    
    disub_kunnr
    
 , 
    cast(null as TEXT) as 
    
    disub_owner
    
 , 
    cast(null as TEXT) as 
    
    disub_posnr
    
 , 
    cast(null as TEXT) as 
    
    disub_pspnr
    
 , 
    cast(null as TEXT) as 
    
    disub_sobkz
    
 , 
    cast(null as TEXT) as 
    
    disub_vbeln
    
 , 
    cast(null as numeric(28,6)) as 
    
    dpamt
    
 , 
    cast(null as TEXT) as 
    
    dpdat
    
 , 
    cast(null as numeric(28,6)) as 
    
    dppct
    
 , 
    cast(null as TEXT) as 
    
    dptyp
    
 , 
    cast(null as TEXT) as 
    
    drdat
    
 , 
    cast(null as TEXT) as 
    
    druhr
    
 , 
    cast(null as TEXT) as 
    
    drunr
    
 , 
    cast(null as TEXT) as 
    
    ean11
    
 , 
    cast(null as TEXT) as 
    
    ebeln
    
 , 
    cast(null as TEXT) as 
    
    ebelp
    
 , 
    cast(null as TEXT) as 
    
    ebon2
    
 , 
    cast(null as TEXT) as 
    
    ebon3
    
 , 
    cast(null as TEXT) as 
    
    ebonf
    
 , 
    cast(null as numeric(28,6)) as 
    
    effwr
    
 , 
    cast(null as TEXT) as 
    
    eglkz
    
 , 
    cast(null as TEXT) as 
    
    ehtyp
    
 , 
    cast(null as TEXT) as 
    
    eildt
    
 , 
    cast(null as TEXT) as 
    
    ekkol
    
 , 
    cast(null as TEXT) as 
    
    elikz
    
 , 
    cast(null as TEXT) as 
    
    ematn
    
 , 
    cast(null as TEXT) as 
    
    emlif
    
 , 
    cast(null as TEXT) as 
    
    emnfr
    
 , 
    cast(null as TEXT) as 
    
    empst
    
 , 
    cast(null as TEXT) as 
    
    erekz
    
 , 
    cast(null as TEXT) as 
    
    etdrk
    
 , 
    cast(null as numeric(28,6)) as 
    
    etfz1
    
 , 
    cast(null as numeric(28,6)) as 
    
    etfz2
    
 , 
    cast(null as TEXT) as 
    
    evers
    
 , 
    cast(null as TEXT) as 
    
    excpe
    
 , 
    cast(null as TEXT) as 
    
    exlin
    
 , 
    cast(null as TEXT) as 
    
    exsnr
    
 , 
    cast(null as TEXT) as 
    
    ext_rfx_item
    
 , 
    cast(null as TEXT) as 
    
    ext_rfx_number
    
 , 
    cast(null as TEXT) as 
    
    ext_rfx_system
    
 , 
    cast(null as TEXT) as 
    
    fabkz
    
 , 
    cast(null as numeric(28,6)) as 
    
    ffzhi
    
 , 
    cast(null as TEXT) as 
    
    fipos
    
 , 
    cast(null as TEXT) as 
    
    fiscal_incentive
    
 , 
    cast(null as TEXT) as 
    
    fiscal_incentive_id
    
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
    
    fls_rsto
    
 , 
    cast(null as TEXT) as 
    
    fmfgus_key
    
 , 
    cast(null as TEXT) as 
    
    fplnr
    
 , 
    cast(null as TEXT) as 
    
    fsh_atp_date
    
 , 
    cast(null as TEXT) as 
    
    fsh_collection
    
 , 
    cast(null as TEXT) as 
    
    fsh_grid_cond_rec
    
 , 
    cast(null as TEXT) as 
    
    fsh_item
    
 , 
    cast(null as TEXT) as 
    
    fsh_item_group
    
 , 
    cast(null as TEXT) as 
    
    fsh_psm_pfm_split
    
 , 
    cast(null as TEXT) as 
    
    fsh_season
    
 , 
    cast(null as TEXT) as 
    
    fsh_season_year
    
 , 
    cast(null as TEXT) as 
    
    fsh_ss
    
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
    
    geber
    
 , 
    cast(null as TEXT) as 
    
    gewei
    
 , 
    cast(null as numeric(28,6)) as 
    
    gnetwr
    
 , 
    cast(null as TEXT) as 
    
    grant_nbr
    
 , 
    cast(null as TEXT) as 
    
    handoverloc
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    idnlf
    
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
    
    infnr
    
 , 
    cast(null as TEXT) as 
    
    insmk
    
 , 
    cast(null as TEXT) as 
    
    insnc
    
 , 
    cast(null as TEXT) as 
    
    iprkz
    
 , 
    cast(null as TEXT) as 
    
    itcons
    
 , 
    cast(null as TEXT) as 
    
    iuid_relevant
    
 , 
    cast(null as TEXT) as 
    
    j_1aidatep
    
 , 
    cast(null as TEXT) as 
    
    j_1aindxp
    
 , 
    cast(null as TEXT) as 
    
    j_1bindust
    
 , 
    cast(null as TEXT) as 
    
    j_1bmatorg
    
 , 
    cast(null as TEXT) as 
    
    j_1bmatuse
    
 , 
    cast(null as TEXT) as 
    
    j_1bnbm
    
 , 
    cast(null as TEXT) as 
    
    j_1bownpro
    
 , 
    cast(null as TEXT) as 
    
    kanba
    
 , 
    cast(null as TEXT) as 
    
    kblnr
    
 , 
    cast(null as TEXT) as 
    
    kblpos
    
 , 
    cast(null as TEXT) as 
    
    knttp
    
 , 
    cast(null as TEXT) as 
    
    ko_gsber
    
 , 
    cast(null as TEXT) as 
    
    ko_pargb
    
 , 
    cast(null as TEXT) as 
    
    ko_pprctr
    
 , 
    cast(null as TEXT) as 
    
    ko_prctr
    
 , 
    cast(null as TEXT) as 
    
    kolif
    
 , 
    cast(null as TEXT) as 
    
    konnr
    
 , 
    cast(null as numeric(28,6)) as 
    
    ktmng
    
 , 
    cast(null as TEXT) as 
    
    ktpnr
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    kzabs
    
 , 
    cast(null as TEXT) as 
    
    kzbws
    
 , 
    cast(null as TEXT) as 
    
    kzfme
    
 , 
    cast(null as TEXT) as 
    
    kzkfg
    
 , 
    cast(null as TEXT) as 
    
    kzstu
    
 , 
    cast(null as TEXT) as 
    
    kztlf
    
 , 
    cast(null as TEXT) as 
    
    kzvbr
    
 , 
    cast(null as numeric(28,6)) as 
    
    kzwi1
    
 , 
    cast(null as numeric(28,6)) as 
    
    kzwi2
    
 , 
    cast(null as numeric(28,6)) as 
    
    kzwi3
    
 , 
    cast(null as numeric(28,6)) as 
    
    kzwi4
    
 , 
    cast(null as numeric(28,6)) as 
    
    kzwi5
    
 , 
    cast(null as numeric(28,6)) as 
    
    kzwi6
    
 , 
    cast(null as TEXT) as 
    
    labnr
    
 , 
    cast(null as TEXT) as 
    
    lblkz
    
 , 
    cast(null as TEXT) as 
    
    lebre
    
 , 
    cast(null as TEXT) as 
    
    lewed
    
 , 
    cast(null as TEXT) as 
    
    lfret
    
 , 
    cast(null as TEXT) as 
    
    lgort
    
 , 
    cast(null as TEXT) as 
    
    lmein
    
 , 
    cast(null as TEXT) as 
    
    loekz
    
 , 
    cast(null as TEXT) as 
    
    ltsnr
    
 , 
    cast(null as numeric(28,6)) as 
    
    mahn1
    
 , 
    cast(null as numeric(28,6)) as 
    
    mahn2
    
 , 
    cast(null as numeric(28,6)) as 
    
    mahn3
    
 , 
    cast(null as numeric(28,6)) as 
    
    mahnz
    
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
    
    meins
    
 , 
    cast(null as numeric(28,6)) as 
    
    menge
    
 , 
    cast(null as TEXT) as 
    
    meprf
    
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
    
    mfzhi
    
 , 
    cast(null as numeric(28,6)) as 
    
    mhdrz
    
 , 
    cast(null as TEXT) as 
    
    mlmaa
    
 , 
    cast(null as TEXT) as 
    
    mprof
    
 , 
    cast(null as TEXT) as 
    
    mrpind
    
 , 
    cast(null as TEXT) as 
    
    mtart
    
 , 
    cast(null as TEXT) as 
    
    mwskz
    
 , 
    cast(null as numeric(28,6)) as 
    
    navnw
    
 , 
    cast(null as numeric(28,6)) as 
    
    netpr
    
 , 
    cast(null as numeric(28,6)) as 
    
    netwr
    
 , 
    cast(null as TEXT) as 
    
    nfabd
    
 , 
    cast(null as TEXT) as 
    
    nlabd
    
 , 
    cast(null as TEXT) as 
    
    notkz
    
 , 
    cast(null as TEXT) as 
    
    novet
    
 , 
    cast(null as TEXT) as 
    
    nrfhg
    
 , 
    cast(null as numeric(28,6)) as 
    
    ntgew
    
 , 
    cast(null as TEXT) as 
    
    oia_baselo
    
 , 
    cast(null as TEXT) as 
    
    oia_ipmvat
    
 , 
    cast(null as TEXT) as 
    
    oia_spltiv
    
 , 
    cast(null as TEXT) as 
    
    oibasprod
    
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
    
    oic_dregio
    
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
    
    oicertf1
    
 , 
    cast(null as TEXT) as 
    
    oicertf1_gi
    
 , 
    cast(null as TEXT) as 
    
    oid_extbol
    
 , 
    cast(null as TEXT) as 
    
    oid_miscdl
    
 , 
    cast(null as TEXT) as 
    
    oidatfm1
    
 , 
    cast(null as TEXT) as 
    
    oidatfm1_gi
    
 , 
    cast(null as TEXT) as 
    
    oidatto1
    
 , 
    cast(null as TEXT) as 
    
    oidatto1_gi
    
 , 
    cast(null as TEXT) as 
    
    oiedbal
    
 , 
    cast(null as TEXT) as 
    
    oiedbal_gi
    
 , 
    cast(null as TEXT) as 
    
    oiedbalm
    
 , 
    cast(null as TEXT) as 
    
    oiedbalm_gi
    
 , 
    cast(null as TEXT) as 
    
    oiedok
    
 , 
    cast(null as TEXT) as 
    
    oiedok_gi
    
 , 
    cast(null as TEXT) as 
    
    oiexgnum
    
 , 
    cast(null as TEXT) as 
    
    oiexgtyp
    
 , 
    cast(null as TEXT) as 
    
    oiextnr
    
 , 
    cast(null as TEXT) as 
    
    oifeech
    
 , 
    cast(null as TEXT) as 
    
    oifeedt
    
 , 
    cast(null as numeric(28,6)) as 
    
    oifeetot
    
 , 
    cast(null as TEXT) as 
    
    oiferp
    
 , 
    cast(null as TEXT) as 
    
    oiftind
    
 , 
    cast(null as TEXT) as 
    
    oighndl
    
 , 
    cast(null as numeric(28,6)) as 
    
    oih_folqty
    
 , 
    cast(null as numeric(28,6)) as 
    
    oih_folqty_gi
    
 , 
    cast(null as TEXT) as 
    
    oih_lcfol
    
 , 
    cast(null as TEXT) as 
    
    oih_lcfol_gi
    
 , 
    cast(null as TEXT) as 
    
    oih_licin
    
 , 
    cast(null as TEXT) as 
    
    oih_licin_gi
    
 , 
    cast(null as TEXT) as 
    
    oih_lictp
    
 , 
    cast(null as TEXT) as 
    
    oih_lictp_gi
    
 , 
    cast(null as TEXT) as 
    
    oihantyp
    
 , 
    cast(null as TEXT) as 
    
    oihantyp_gi
    
 , 
    cast(null as TEXT) as 
    
    oiinex
    
 , 
    cast(null as TEXT) as 
    
    oiinex_gi
    
 , 
    cast(null as TEXT) as 
    
    oiitmnr
    
 , 
    cast(null as TEXT) as 
    
    oimatcyc
    
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
    
    oipricie
    
 , 
    cast(null as TEXT) as 
    
    oipriop
    
 , 
    cast(null as TEXT) as 
    
    oisbrel
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitaxcon
    
 , 
    cast(null as TEXT) as 
    
    oitaxfrom
    
 , 
    cast(null as TEXT) as 
    
    oitaxgrp
    
 , 
    cast(null as TEXT) as 
    
    oitaxgrp_gi
    
 , 
    cast(null as TEXT) as 
    
    oitaxto
    
 , 
    cast(null as TEXT) as 
    
    oitrind
    
 , 
    cast(null as TEXT) as 
    
    oitrkjr
    
 , 
    cast(null as TEXT) as 
    
    oitrknr
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitxcon1
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitxcon2
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitxcon3
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitxcon4
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitxcon5
    
 , 
    cast(null as numeric(28,6)) as 
    
    oitxcon6
    
 , 
    cast(null as TEXT) as 
    
    oiumbar
    
 , 
    cast(null as numeric(28,6)) as 
    
    oivatf
    
 , 
    cast(null as numeric(28,6)) as 
    
    oivath
    
 , 
    cast(null as TEXT) as 
    
    packno
    
 , 
    cast(null as numeric(28,6)) as 
    
    peinh
    
 , 
    cast(null as numeric(28,6)) as 
    
    plifz
    
 , 
    cast(null as TEXT) as 
    
    pol_id
    
 , 
    cast(null as TEXT) as 
    
    prdat
    
 , 
    cast(null as TEXT) as 
    
    prio_req
    
 , 
    cast(null as TEXT) as 
    
    prio_urg
    
 , 
    cast(null as TEXT) as 
    
    prsdr
    
 , 
    cast(null as TEXT) as 
    
    pstyp
    
 , 
    cast(null as TEXT) as 
    
    punei
    
 , 
    cast(null as TEXT) as 
    
    put_back
    
 , 
    cast(null as TEXT) as 
    
    rdprf
    
 , 
    cast(null as TEXT) as 
    
    reason_code
    
 , 
    cast(null as TEXT) as 
    
    ref_item
    
 , 
    cast(null as TEXT) as 
    
    refsite
    
 , 
    cast(null as TEXT) as 
    
    repos
    
 , 
    cast(null as TEXT) as 
    
    reslo
    
 , 
    cast(null as numeric(28,6)) as 
    
    retpc
    
 , 
    cast(null as TEXT) as 
    
    retpo
    
 , 
    cast(null as TEXT) as 
    
    revlv
    
 , 
    cast(null as TEXT) as 
    
    saisj
    
 , 
    cast(null as TEXT) as 
    
    saiso
    
 , 
    cast(null as TEXT) as 
    
    satnr
    
 , 
    cast(null as TEXT) as 
    
    schpr
    
 , 
    cast(null as TEXT) as 
    
    sernp
    
 , 
    cast(null as TEXT) as 
    
    serru
    
 , 
    cast(null as TEXT) as 
    
    sf_txjcd
    
 , 
    cast(null as TEXT) as 
    
    sgt_rcat
    
 , 
    cast(null as TEXT) as 
    
    sgt_scat
    
 , 
    cast(null as TEXT) as 
    
    sikgr
    
 , 
    cast(null as TEXT) as 
    
    sktof
    
 , 
    cast(null as TEXT) as 
    
    sobkz
    
 , 
    cast(null as TEXT) as 
    
    source_id
    
 , 
    cast(null as TEXT) as 
    
    source_key
    
 , 
    cast(null as TEXT) as 
    
    spe_abgru
    
 , 
    cast(null as TEXT) as 
    
    spe_chng_sys
    
 , 
    cast(null as TEXT) as 
    
    spe_cq_ctrltype
    
 , 
    cast(null as TEXT) as 
    
    spe_cq_nocq
    
 , 
    cast(null as TEXT) as 
    
    spe_crm_fkrel
    
 , 
    cast(null as TEXT) as 
    
    spe_crm_ref_item
    
 , 
    cast(null as TEXT) as 
    
    spe_crm_ref_so
    
 , 
    cast(null as TEXT) as 
    
    spe_crm_so
    
 , 
    cast(null as TEXT) as 
    
    spe_crm_so_item
    
 , 
    cast(null as TEXT) as 
    
    spe_ewm_dtc
    
 , 
    cast(null as TEXT) as 
    
    spe_insmk_src
    
 , 
    cast(null as TEXT) as 
    
    spinf
    
 , 
    cast(null as TEXT) as 
    
    srm_contract_id
    
 , 
    cast(null as TEXT) as 
    
    srm_contract_itm
    
 , 
    cast(null as TEXT) as 
    
    srv_bas_com
    
 , 
    cast(null as TEXT) as 
    
    ssqss
    
 , 
    cast(null as TEXT) as 
    
    stafo
    
 , 
    cast(null as TEXT) as 
    
    stapo
    
 , 
    cast(null as TEXT) as 
    
    statu
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    tax_subject_st
    
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
    
    twrkz
    
 , 
    cast(null as TEXT) as 
    
    txjcd
    
 , 
    cast(null as TEXT) as 
    
    txz01
    
 , 
    cast(null as TEXT) as 
    
    tzonrc
    
 , 
    cast(null as TEXT) as 
    
    uebpo
    
 , 
    cast(null as TEXT) as 
    
    uebtk
    
 , 
    cast(null as numeric(28,6)) as 
    
    uebto
    
 , 
    cast(null as numeric(28,6)) as 
    
    umren
    
 , 
    cast(null as numeric(28,6)) as 
    
    umrez
    
 , 
    cast(null as TEXT) as 
    
    umsok
    
 , 
    cast(null as numeric(28,6)) as 
    
    untto
    
 , 
    cast(null as TEXT) as 
    
    uptyp
    
 , 
    cast(null as TEXT) as 
    
    upvor
    
 , 
    cast(null as TEXT) as 
    
    usequ
    
 , 
    cast(null as TEXT) as 
    
    voleh
    
 , 
    cast(null as numeric(28,6)) as 
    
    volum
    
 , 
    cast(null as TEXT) as 
    
    vorab
    
 , 
    cast(null as TEXT) as 
    
    vrtkz
    
 , 
    cast(null as TEXT) as 
    
    vsart
    
 , 
    cast(null as TEXT) as 
    
    wabwe
    
 , 
    cast(null as numeric(28,6)) as 
    
    webaz
    
 , 
    cast(null as TEXT) as 
    
    webre
    
 , 
    cast(null as TEXT) as 
    
    weora
    
 , 
    cast(null as TEXT) as 
    
    wepos
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    weunb
    
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
    
    xconditions
    
 , 
    cast(null as TEXT) as 
    
    xersy
    
 , 
    cast(null as TEXT) as 
    
    xoblr
    
 , 
    cast(null as TEXT) as 
    
    zgtyp
    
 , 
    cast(null as numeric(28,6)) as 
    
    zwert
    
 , 
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
    
    _accgo_is_co_rel
    
 , 
    cast(null as TEXT) as 
    
    _bev1_nedepfree
    
 , 
    cast(null as TEXT) as 
    
    _bev1_negen_item
    
 , 
    cast(null as TEXT) as 
    
    _bev1_nestruccat
    
 


    from base
),

final as (
    select
        _accgo_is_co_rel,
        _bev1_nedepfree,
        _bev1_negen_item,
        _bev1_nestruccat,
        abdat,
        abeln,
        abelp,
        abftz,
        abmng,
        abskz,
        abueb,
        adrn2,
        adrnr,
        advcode,
        aedat,
        afnam,
        agdat,
        agmem,
        aktnr,
        anfnr,
        anfps,
        anzpu,
        anzsn,
        apoms,
        arsnr,
        arsps,
        attyp,
        aurel,
        banfn,
        bednr,
        berid,
        blk_reason_id,
        blk_reason_txt,
        bnfpo,
        bonba,
        bonus,
        bprme,
        bpumn,
        bpumz,
        brgew,
        brtwr,
        bsgru,
        bstae,
        bstyp,
        budget_pd,
        cast(bukrs as TEXT) as bukrs,
        bwtar,
        bwtty,
        ccomp,
        chg_fplnr,
        chg_srv,
        cmpl_dlv_itm,
        cnfm_qty,
        cons_order,
        cqu_sar,
        cuobj,
        diff_invoice,
        disub_kunnr,
        disub_owner,
        disub_posnr,
        disub_pspnr,
        disub_sobkz,
        disub_vbeln,
        dpamt,
        dpdat,
        dppct,
        dptyp,
        drdat,
        druhr,
        drunr,
        ean11,
        cast(ebeln as TEXT) as ebeln,
        cast(ebelp as TEXT) as ebelp,
        ebon2,
        ebon3,
        ebonf,
        effwr,
        eglkz,
        ehtyp,
        eildt,
        ekkol,
        elikz,
        ematn,
        emlif,
        emnfr,
        empst,
        erekz,
        etdrk,
        etfz1,
        etfz2,
        evers,
        excpe,
        exlin,
        exsnr,
        ext_rfx_item,
        ext_rfx_number,
        ext_rfx_system,
        fabkz,
        ffzhi,
        fipos,
        fiscal_incentive,
        fiscal_incentive_id,
        fistl,
        fixmg,
        fkber,
        fls_rsto,
        fmfgus_key,
        fplnr,
        fsh_atp_date,
        fsh_collection,
        fsh_grid_cond_rec,
        fsh_item,
        fsh_item_group,
        fsh_psm_pfm_split,
        fsh_season,
        fsh_season_year,
        fsh_ss,
        fsh_theme,
        fsh_transaction,
        fsh_vas_prnt_id,
        fsh_vas_rel,
        geber,
        gewei,
        gnetwr,
        grant_nbr,
        handoverloc,
        hvr_change_time,
        hvr_is_deleted,
        idnlf,
        inco1,
        inco2,
        inco2_l,
        inco3_l,
        infnr,
        insmk,
        insnc,
        iprkz,
        itcons,
        iuid_relevant,
        j_1aidatep,
        j_1aindxp,
        j_1bindust,
        j_1bmatorg,
        j_1bmatuse,
        j_1bnbm,
        j_1bownpro,
        kanba,
        kblnr,
        kblpos,
        knttp,
        ko_gsber,
        ko_pargb,
        ko_pprctr,
        ko_prctr,
        kolif,
        konnr,
        ktmng,
        ktpnr,
        cast(kunnr as TEXT) as kunnr,
        kzabs,
        kzbws,
        kzfme,
        kzkfg,
        kzstu,
        kztlf,
        kzvbr,
        kzwi1,
        kzwi2,
        kzwi3,
        kzwi4,
        kzwi5,
        kzwi6,
        labnr,
        lblkz,
        lebre,
        lewed,
        lfret,
        lgort,
        lmein,
        loekz,
        ltsnr,
        mahn1,
        mahn2,
        mahn3,
        mahnz,
        cast(mandt as TEXT) as mandt,
        manual_tc_reason,
        matkl,
        cast(matnr as TEXT) as matnr,
        meins,
        cast(menge as numeric(28,6)) as menge,
        meprf,
        mfrgr,
        mfrnr,
        mfrpn,
        mfzhi,
        mhdrz,
        mlmaa,
        mprof,
        mrpind,
        mtart,
        mwskz,
        navnw,
        netpr,
        cast(netwr as numeric(28,6)) as netwr,
        nfabd,
        nlabd,
        notkz,
        novet,
        nrfhg,
        ntgew,
        oia_baselo,
        oia_ipmvat,
        oia_spltiv,
        oibasprod,
        oic_adestn,
        oic_aorgin,
        oic_dcityc,
        oic_dcounc,
        oic_dland1,
        oic_dregio,
        oic_lifnr,
        oic_mot,
        oic_ocityc,
        oic_ocounc,
        oic_oland1,
        oic_oregio,
        oic_pbatch,
        oic_pdestn,
        oic_porgin,
        oic_ptrip,
        oic_truckn,
        oicertf1,
        oicertf1_gi,
        oid_extbol,
        oid_miscdl,
        oidatfm1,
        oidatfm1_gi,
        oidatto1,
        oidatto1_gi,
        oiedbal,
        oiedbal_gi,
        oiedbalm,
        oiedbalm_gi,
        oiedok,
        oiedok_gi,
        oiexgnum,
        oiexgtyp,
        oiextnr,
        oifeech,
        oifeedt,
        oifeetot,
        oiferp,
        oiftind,
        oighndl,
        oih_folqty,
        oih_folqty_gi,
        oih_lcfol,
        oih_lcfol_gi,
        oih_licin,
        oih_licin_gi,
        oih_lictp,
        oih_lictp_gi,
        oihantyp,
        oihantyp_gi,
        oiinex,
        oiinex_gi,
        oiitmnr,
        oimatcyc,
        oinetcyc,
        oioilcon,
        oipipeval,
        oipricie,
        oipriop,
        oisbrel,
        oitaxcon,
        oitaxfrom,
        oitaxgrp,
        oitaxgrp_gi,
        oitaxto,
        oitrind,
        oitrkjr,
        oitrknr,
        oitxcon1,
        oitxcon2,
        oitxcon3,
        oitxcon4,
        oitxcon5,
        oitxcon6,
        oiumbar,
        oivatf,
        oivath,
        packno,
        peinh,
        plifz,
        pol_id,
        prdat,
        prio_req,
        prio_urg,
        prsdr,
        pstyp,
        punei,
        put_back,
        rdprf,
        reason_code,
        ref_item,
        refsite,
        repos,
        reslo,
        retpc,
        retpo,
        revlv,
        saisj,
        saiso,
        satnr,
        schpr,
        sernp,
        serru,
        sf_txjcd,
        sgt_rcat,
        sgt_scat,
        sikgr,
        sktof,
        sobkz,
        source_id,
        source_key,
        spe_abgru,
        spe_chng_sys,
        spe_cq_ctrltype,
        spe_cq_nocq,
        spe_crm_fkrel,
        spe_crm_ref_item,
        spe_crm_ref_so,
        spe_crm_so,
        spe_crm_so_item,
        spe_ewm_dtc,
        spe_insmk_src,
        spinf,
        srm_contract_id,
        srm_contract_itm,
        srv_bas_com,
        ssqss,
        stafo,
        stapo,
        statu,
        status,
        tax_subject_st,
        tc_aut_det,
        techs,
        trmrisk_relevant,
        twrkz,
        txjcd,
        txz01,
        tzonrc,
        uebpo,
        uebtk,
        uebto,
        umren,
        umrez,
        umsok,
        untto,
        uptyp,
        upvor,
        usequ,
        voleh,
        volum,
        vorab,
        vrtkz,
        vsart,
        wabwe,
        webaz,
        webre,
        weora,
        wepos,
        werks,
        weunb,
        wrf_charstc1,
        wrf_charstc2,
        wrf_charstc3,
        xconditions,
        xersy,
        xoblr,
        zgtyp,
        zwert,
        _fivetran_sap_archived,
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced
    from fields
)

select *
from final
