with base as (
    select 
    from "sap"."main_sap"."stg_sap__vbak_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    vbeln
    
 , 
    cast(null as TEXT) as 
    
    kostl
    
 , 
    cast(null as TEXT) as 
    
    mahza
    
 , 
    cast(null as TEXT) as 
    
    msr_id
    
 , 
    cast(null as TEXT) as 
    
    _dataaging
    
 , 
    cast(null as TEXT) as 
    
    taxk5
    
 , 
    cast(null as TEXT) as 
    
    kvgr4
    
 , 
    cast(null as TEXT) as 
    
    amtbl
    
 , 
    cast(null as TEXT) as 
    
    trvog
    
 , 
    cast(null as TEXT) as 
    
    hb_resdate
    
 , 
    cast(null as TEXT) as 
    
    fmbdat
    
 , 
    cast(null as TEXT) as 
    
    fsh_vrsn_status
    
 , 
    cast(null as TEXT) as 
    
    upd_tmstmp
    
 , 
    cast(null as TEXT) as 
    
    auart
    
 , 
    cast(null as TEXT) as 
    
    hb_expdate
    
 , 
    cast(null as TEXT) as 
    
    scheme_grp
    
 , 
    cast(null as TEXT) as 
    
    smenr
    
 , 
    cast(null as TEXT) as 
    
    taxk6
    
 , 
    cast(null as TEXT) as 
    
    fsh_transaction
    
 , 
    cast(null as TEXT) as 
    
    kvgr5
    
 , 
    cast(null as TEXT) as 
    
    gskst
    
 , 
    cast(null as TEXT) as 
    
    vkgrp
    
 , 
    cast(null as TEXT) as 
    
    pay_method
    
 , 
    cast(null as TEXT) as 
    
    ktext
    
 , 
    cast(null as TEXT) as 
    
    ps_psp_pnr
    
 , 
    cast(null as TEXT) as 
    
    faksk
    
 , 
    cast(null as TEXT) as 
    
    bnddt
    
 , 
    cast(null as TEXT) as 
    
    cmwae
    
 , 
    cast(null as TEXT) as 
    
    kokrs
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    betc
    
 , 
    cast(null as TEXT) as 
    
    fsh_rereg
    
 , 
    cast(null as TEXT) as 
    
    tas
    
 , 
    cast(null as TEXT) as 
    
    cancel_allow
    
 , 
    cast(null as TEXT) as 
    
    fkara
    
 , 
    cast(null as TEXT) as 
    
    taxk7
    
 , 
    cast(null as TEXT) as 
    
    gwldt
    
 , 
    cast(null as TEXT) as 
    
    psm_budat
    
 , 
    cast(null as TEXT) as 
    
    objnr
    
 , 
    cast(null as TEXT) as 
    
    autlf
    
 , 
    cast(null as TEXT) as 
    
    stwae
    
 , 
    cast(null as TEXT) as 
    
    abhov
    
 , 
    cast(null as TEXT) as 
    
    logsysb
    
 , 
    cast(null as TEXT) as 
    
    fsh_kvgr6
    
 , 
    cast(null as TEXT) as 
    
    bname
    
 , 
    cast(null as TEXT) as 
    
    taxk8
    
 , 
    cast(null as TEXT) as 
    
    xblnr
    
 , 
    cast(null as TEXT) as 
    
    mtlaur
    
 , 
    cast(null as TEXT) as 
    
    augru
    
 , 
    cast(null as TEXT) as 
    
    stafo
    
 , 
    cast(null as TEXT) as 
    
    swenr
    
 , 
    cast(null as TEXT) as 
    
    _xlso_trans_ctxt
    
 , 
    cast(null as TEXT) as 
    
    abruf_part
    
 , 
    cast(null as TEXT) as 
    
    cmngv
    
 , 
    cast(null as TEXT) as 
    
    knkli
    
 , 
    cast(null as TEXT) as 
    
    spart
    
 , 
    cast(null as TEXT) as 
    
    proli
    
 , 
    cast(null as TEXT) as 
    
    enqueue_grp
    
 , 
    cast(null as TEXT) as 
    
    vzeit
    
 , 
    cast(null as TEXT) as 
    
    kalcd
    
 , 
    cast(null as TEXT) as 
    
    bukrs_vf
    
 , 
    cast(null as TEXT) as 
    
    fsh_kvgr7
    
 , 
    cast(null as TEXT) as 
    
    vprgr
    
 , 
    cast(null as TEXT) as 
    
    crm_guid
    
 , 
    cast(null as TEXT) as 
    
    hityp_pr
    
 , 
    cast(null as TEXT) as 
    
    taxk9
    
 , 
    cast(null as TEXT) as 
    
    vgbel
    
 , 
    cast(null as TEXT) as 
    
    erzet
    
 , 
    cast(null as TEXT) as 
    
    ihrez
    
 , 
    cast(null as TEXT) as 
    
    submi
    
 , 
    cast(null as TEXT) as 
    
    vdatu
    
 , 
    cast(null as TEXT) as 
    
    _xlso_variant_id
    
 , 
    cast(null as TEXT) as 
    
    abdis
    
 , 
    cast(null as TEXT) as 
    
    fsh_kvgr8
    
 , 
    cast(null as TEXT) as 
    
    ernam
    
 , 
    cast(null as TEXT) as 
    
    hb_cont_reason
    
 , 
    cast(null as integer) as 
    
    netwr
    
 , 
    cast(null as TEXT) as 
    
    vbkla
    
 , 
    cast(null as TEXT) as 
    
    vgtyp
    
 , 
    cast(null as TEXT) as 
    
    sbgrp
    
 , 
    cast(null as TEXT) as 
    
    stceg_l
    
 , 
    cast(null as TEXT) as 
    
    fsh_kvgr10
    
 , 
    cast(null as TEXT) as 
    
    knuma
    
 , 
    cast(null as TEXT) as 
    
    fsh_ss
    
 , 
    cast(null as TEXT) as 
    
    fsh_cq_check
    
 , 
    cast(null as TEXT) as 
    
    xegdr
    
 , 
    cast(null as TEXT) as 
    
    bstnk
    
 , 
    cast(null as TEXT) as 
    
    multi
    
 , 
    cast(null as TEXT) as 
    
    sppaym
    
 , 
    cast(null as TEXT) as 
    
    lifsk
    
 , 
    cast(null as TEXT) as 
    
    fsh_kvgr9
    
 , 
    cast(null as TEXT) as 
    
    aedat
    
 , 
    cast(null as TEXT) as 
    
    wtysc_clm_hdr
    
 , 
    cast(null as TEXT) as 
    
    dat_fzau
    
 , 
    cast(null as TEXT) as 
    
    awahr
    
 , 
    cast(null as TEXT) as 
    
    kurst
    
 , 
    cast(null as TEXT) as 
    
    gueen
    
 , 
    cast(null as TEXT) as 
    
    _xlso_so_vald_to
    
 , 
    cast(null as TEXT) as 
    
    cmnup
    
 , 
    cast(null as TEXT) as 
    
    abhod
    
 , 
    cast(null as TEXT) as 
    
    vkorg
    
 , 
    cast(null as TEXT) as 
    
    audat
    
 , 
    cast(null as TEXT) as 
    
    zuonr
    
 , 
    cast(null as TEXT) as 
    
    angdt
    
 , 
    cast(null as TEXT) as 
    
    vsbed
    
 , 
    cast(null as TEXT) as 
    
    _xlso_payment_op
    
 , 
    cast(null as TEXT) as 
    
    rep_freq
    
 , 
    cast(null as TEXT) as 
    
    handle
    
 , 
    cast(null as TEXT) as 
    
    _xlso_so_vald_fm
    
 , 
    cast(null as TEXT) as 
    
    bstzd
    
 , 
    cast(null as TEXT) as 
    
    taxk1
    
 , 
    cast(null as TEXT) as 
    
    mahdt
    
 , 
    cast(null as TEXT) as 
    
    bstdk
    
 , 
    cast(null as TEXT) as 
    
    vbeln_grp
    
 , 
    cast(null as TEXT) as 
    
    handoverloc
    
 , 
    cast(null as TEXT) as 
    
    qmnum
    
 , 
    cast(null as TEXT) as 
    
    kalsm_ch
    
 , 
    cast(null as TEXT) as 
    
    cont_dg
    
 , 
    cast(null as TEXT) as 
    
    cmfre
    
 , 
    cast(null as TEXT) as 
    
    vtweg
    
 , 
    cast(null as TEXT) as 
    
    telf1
    
 , 
    cast(null as TEXT) as 
    
    aufnr
    
 , 
    cast(null as TEXT) as 
    
    phase
    
 , 
    cast(null as TEXT) as 
    
    taxk2
    
 , 
    cast(null as TEXT) as 
    
    kvgr1
    
 , 
    cast(null as TEXT) as 
    
    grupp
    
 , 
    cast(null as TEXT) as 
    
    fsh_os_stg_change
    
 , 
    cast(null as TEXT) as 
    
    abhob
    
 , 
    cast(null as TEXT) as 
    
    landtx
    
 , 
    cast(null as TEXT) as 
    
    kalsm
    
 , 
    cast(null as TEXT) as 
    
    erdat
    
 , 
    cast(null as TEXT) as 
    
    bpn
    
 , 
    cast(null as TEXT) as 
    
    stage
    
 , 
    cast(null as TEXT) as 
    
    kkber
    
 , 
    cast(null as TEXT) as 
    
    taxk3
    
 , 
    cast(null as TEXT) as 
    
    abrvw
    
 , 
    cast(null as TEXT) as 
    
    vbtyp
    
 , 
    cast(null as TEXT) as 
    
    kvgr2
    
 , 
    cast(null as TEXT) as 
    
    knumv
    
 , 
    cast(null as TEXT) as 
    
    guebg
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_cg
    
 , 
    cast(null as TEXT) as 
    
    waerk
    
 , 
    cast(null as TEXT) as 
    
    vkbur
    
 , 
    cast(null as TEXT) as 
    
    ctlpc
    
 , 
    cast(null as TEXT) as 
    
    vsnmr_v
    
 , 
    cast(null as TEXT) as 
    
    rplnr
    
 , 
    cast(null as TEXT) as 
    
    vbklt
    
 , 
    cast(null as TEXT) as 
    
    mod_allow
    
 , 
    cast(null as TEXT) as 
    
    taxk4
    
 , 
    cast(null as TEXT) as 
    
    _xlso_catalog_id
    
 , 
    cast(null as TEXT) as 
    
    kvgr3
    
 , 
    cast(null as TEXT) as 
    
    fsh_candate
    
 , 
    cast(null as TEXT) as 
    
    agrzr
    
 , 
    cast(null as TEXT) as 
    
    mill_appl_id
    
 , 
    cast(null as TEXT) as 
    
    bsark
    
 , 
    cast(null as TEXT) as 
    
    tm_ctrl_key
    
 , 
    cast(null as TEXT) as 
    
    gsber
    
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
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived,
        cast(mandt as TEXT) as mandt,
        cast(vbeln as TEXT) as vbeln,
        kostl,
        mahza,
        msr_id,
        _dataaging,
        taxk5,
        kvgr4,
        amtbl,
        trvog,
        hb_resdate,
        fmbdat,
        fsh_vrsn_status,
        upd_tmstmp,
        auart,
        hb_expdate,
        scheme_grp,
        smenr,
        taxk6,
        fsh_transaction,
        kvgr5,
        gskst,
        vkgrp,
        pay_method,
        ktext,
        ps_psp_pnr,
        faksk,
        bnddt,
        cmwae,
        kokrs,
        cast(kunnr as TEXT) as kunnr,
        betc,
        fsh_rereg,
        tas,
        cancel_allow,
        fkara,
        taxk7,
        gwldt,
        psm_budat,
        objnr,
        autlf,
        stwae,
        abhov,
        logsysb,
        fsh_kvgr6,
        bname,
        taxk8,
        xblnr,
        mtlaur,
        augru,
        stafo,
        swenr,
        _xlso_trans_ctxt,
        abruf_part,
        cmngv,
        knkli,
        spart,
        proli,
        enqueue_grp,
        vzeit,
        kalcd,
        bukrs_vf,
        fsh_kvgr7,
        vprgr,
        crm_guid,
        hityp_pr,
        taxk9,
        vgbel,
        erzet,
        ihrez,
        submi,
        vdatu,
        _xlso_variant_id,
        abdis,
        fsh_kvgr8,
        ernam,
        hb_cont_reason,
        cast(netwr as numeric(28,6)) as netwr,
        vbkla,
        vgtyp,
        sbgrp,
        stceg_l,
        fsh_kvgr10,
        knuma,
        fsh_ss,
        fsh_cq_check,
        xegdr,
        bstnk,
        multi,
        sppaym,
        lifsk,
        fsh_kvgr9,
        aedat,
        wtysc_clm_hdr,
        dat_fzau,
        awahr,
        kurst,
        gueen,
        _xlso_so_vald_to,
        cmnup,
        abhod,
        vkorg,
        audat,
        zuonr,
        angdt,
        vsbed,
        _xlso_payment_op,
        rep_freq,
        handle,
        _xlso_so_vald_fm,
        bstzd,
        taxk1,
        mahdt,
        bstdk,
        vbeln_grp,
        handoverloc,
        qmnum,
        kalsm_ch,
        cont_dg,
        cmfre,
        vtweg,
        telf1,
        aufnr,
        phase,
        taxk2,
        kvgr1,
        grupp,
        fsh_os_stg_change,
        abhob,
        landtx,
        kalsm,
        erdat,
        bpn,
        stage,
        kkber,
        taxk3,
        abrvw,
        vbtyp,
        kvgr2,
        knumv,
        guebg,
        fsh_vas_cg,
        waerk,
        vkbur,
        ctlpc,
        vsnmr_v,
        rplnr,
        vbklt,
        mod_allow,
        taxk4,
        _xlso_catalog_id,
        kvgr3,
        fsh_candate,
        agrzr,
        mill_appl_id,
        bsark,
        tm_ctrl_key,
        gsber
    from fields
)

select *
from final
