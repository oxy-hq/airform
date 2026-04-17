with base as (

    select 
    from "sap"."main_sap"."stg_sap__matdoc_tmp"
),

fields as (

    select
        
    cast(null as numeric(28,6)) as 
    
    _cwm_consumption_qty
    
 , 
    cast(null as TEXT) as 
    
    _cwm_erfme
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_erfmg
    
 , 
    cast(null as TEXT) as 
    
    _cwm_meins
    
 , 
    cast(null as TEXT) as 
    
    _cwm_meins_sid
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_menge
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_stock_qty
    
 , 
    cast(null as date) as 
    
    _dataaging
    
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
    cast(null as TEXT) as 
    
    ablad
    
 , 
    cast(null as date) as 
    
    aedat
    
 , 
    cast(null as TEXT) as 
    
    aktnr
    
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
    
    ass_pspnr
    
 , 
    cast(null as TEXT) as 
    
    aufnr
    
 , 
    cast(null as TEXT) as 
    
    aufpl
    
 , 
    cast(null as TEXT) as 
    
    aufps
    
 , 
    cast(null as TEXT) as 
    
    awsys
    
 , 
    cast(null as TEXT) as 
    
    belnr
    
 , 
    cast(null as TEXT) as 
    
    belum
    
 , 
    cast(null as TEXT) as 
    
    bemot
    
 , 
    cast(null as TEXT) as 
    
    berid
    
 , 
    cast(null as TEXT) as 
    
    berkz
    
 , 
    cast(null as TEXT) as 
    
    bestq
    
 , 
    cast(null as TEXT) as 
    
    bfwms
    
 , 
    cast(null as TEXT) as 
    
    bktxt
    
 , 
    cast(null as TEXT) as 
    
    bla2d
    
 , 
    cast(null as TEXT) as 
    
    blart
    
 , 
    cast(null as TEXT) as 
    
    blaum
    
 , 
    cast(null as date) as 
    
    bldat
    
 , 
    cast(null as numeric(28,6)) as 
    
    bnbtr
    
 , 
    cast(null as numeric(28,6)) as 
    
    bpmng
    
 , 
    cast(null as TEXT) as 
    
    bprme
    
 , 
    cast(null as TEXT) as 
    
    bstaus_cg
    
 , 
    cast(null as TEXT) as 
    
    bstaus_sg
    
 , 
    cast(null as TEXT) as 
    
    bstme
    
 , 
    cast(null as numeric(28,6)) as 
    
    bstmg
    
 , 
    cast(null as TEXT) as 
    
    bsttyp_cg
    
 , 
    cast(null as TEXT) as 
    
    bsttyp_sg
    
 , 
    cast(null as numeric(28,6)) as 
    
    bualt
    
 , 
    cast(null as date) as 
    
    budat
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    bustm
    
 , 
    cast(null as TEXT) as 
    
    bustw
    
 , 
    cast(null as TEXT) as 
    
    buzei
    
 , 
    cast(null as TEXT) as 
    
    buzum
    
 , 
    cast(null as TEXT) as 
    
    bwart
    
 , 
    cast(null as TEXT) as 
    
    bwlvs
    
 , 
    cast(null as TEXT) as 
    
    bwtar
    
 , 
    cast(null as TEXT) as 
    
    cancellation_type
    
 , 
    cast(null as TEXT) as 
    
    cancelled
    
 , 
    cast(null as TEXT) as 
    
    charg
    
 , 
    cast(null as TEXT) as 
    
    charg_cid
    
 , 
    cast(null as TEXT) as 
    
    charg_sid
    
 , 
    cast(null as TEXT) as 
    
    charg_whs_cg
    
 , 
    cast(null as TEXT) as 
    
    charg_whs_sg
    
 , 
    cast(null as TEXT) as 
    
    compl_mark
    
 , 
    cast(null as TEXT) as 
    
    condi
    
 , 
    cast(null as numeric(28,6)) as 
    
    cons_value_a1
    
 , 
    cast(null as numeric(28,6)) as 
    
    consumption_qty
    
 , 
    cast(null as date) as 
    
    cpudt
    
 , 
    cast(null as TEXT) as 
    
    cputm
    
 , 
    cast(null as TEXT) as 
    
    cuobj_ch
    
 , 
    cast(null as TEXT) as 
    
    currency_a1
    
 , 
    cast(null as date) as 
    
    dabrbz
    
 , 
    cast(null as date) as 
    
    dabrz
    
 , 
    cast(null as TEXT) as 
    
    day_budat
    
 , 
    cast(null as TEXT) as 
    
    disub_owner
    
 , 
    cast(null as TEXT) as 
    
    disub_owner_cid
    
 , 
    cast(null as TEXT) as 
    
    disub_owner_sid
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbtr
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbtr_cons
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbtr_stock
    
 , 
    cast(null as numeric(28,6)) as 
    
    dmbum
    
 , 
    cast(null as TEXT) as 
    
    dummy_incl_eew_cobl
    
 , 
    cast(null as TEXT) as 
    
    dummy_matdoc_incl_eew_ps
    
 , 
    cast(null as TEXT) as 
    
    dypla
    
 , 
    cast(null as TEXT) as 
    
    ebeln
    
 , 
    cast(null as TEXT) as 
    
    ebelp
    
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
    
    equnr
    
 , 
    cast(null as TEXT) as 
    
    erfme
    
 , 
    cast(null as numeric(28,6)) as 
    
    erfmg
    
 , 
    cast(null as TEXT) as 
    
    etanp_mark
    
 , 
    cast(null as TEXT) as 
    
    evere
    
 , 
    cast(null as TEXT) as 
    
    evers
    
 , 
    cast(null as TEXT) as 
    
    ewm_gmdoc
    
 , 
    cast(null as TEXT) as 
    
    ewm_lgnum
    
 , 
    cast(null as TEXT) as 
    
    ewm_lgpla
    
 , 
    cast(null as numeric(28,6)) as 
    
    exbwr
    
 , 
    cast(null as TEXT) as 
    
    exnum
    
 , 
    cast(null as numeric(28,6)) as 
    
    exvkw
    
 , 
    cast(null as date) as 
    
    fbuda
    
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
    
    fls_rsto
    
 , 
    cast(null as numeric(28,6)) as 
    
    frath
    
 , 
    cast(null as TEXT) as 
    
    frbnr
    
 , 
    cast(null as TEXT) as 
    
    fsh_collection
    
 , 
    cast(null as TEXT) as 
    
    fsh_season
    
 , 
    cast(null as TEXT) as 
    
    fsh_season_year
    
 , 
    cast(null as TEXT) as 
    
    fsh_theme
    
 , 
    cast(null as TEXT) as 
    
    fzgls_mark
    
 , 
    cast(null as TEXT) as 
    
    geber
    
 , 
    cast(null as TEXT) as 
    
    gjahr
    
 , 
    cast(null as TEXT) as 
    
    gjper
    
 , 
    cast(null as TEXT) as 
    
    gjper_curr_per
    
 , 
    cast(null as TEXT) as 
    
    grant_nbr
    
 , 
    cast(null as TEXT) as 
    
    grund
    
 , 
    cast(null as TEXT) as 
    
    gsber
    
 , 
    cast(null as TEXT) as 
    
    gts_cusref_no
    
 , 
    cast(null as numeric(28,6)) as 
    
    header_counter
    
 , 
    cast(null as date) as 
    
    hsdat
    
 , 
    cast(null as TEXT) as 
    
    imkey
    
 , 
    cast(null as TEXT) as 
    
    insmk
    
 , 
    cast(null as TEXT) as 
    
    j_1agirupd
    
 , 
    cast(null as numeric(28,6)) as 
    
    j_1bexbase
    
 , 
    cast(null as TEXT) as 
    
    kalnr
    
 , 
    cast(null as TEXT) as 
    
    kalnr_cg
    
 , 
    cast(null as TEXT) as 
    
    kblnr
    
 , 
    cast(null as TEXT) as 
    
    kblpos
    
 , 
    cast(null as TEXT) as 
    
    kdauf
    
 , 
    cast(null as TEXT) as 
    
    kdein
    
 , 
    cast(null as TEXT) as 
    
    kdpos
    
 , 
    cast(null as TEXT) as 
    
    knbdr
    
 , 
    cast(null as TEXT) as 
    
    knttp_gr
    
 , 
    cast(null as TEXT) as 
    
    knumv
    
 , 
    cast(null as TEXT) as 
    
    kokrs
    
 , 
    cast(null as TEXT) as 
    
    kostl
    
 , 
    cast(null as TEXT) as 
    
    kstrg
    
 , 
    cast(null as TEXT) as 
    
    kunnr
    
 , 
    cast(null as TEXT) as 
    
    kunnr_cid
    
 , 
    cast(null as TEXT) as 
    
    kunnr_sid
    
 , 
    cast(null as TEXT) as 
    
    kzbew
    
 , 
    cast(null as TEXT) as 
    
    kzbws
    
 , 
    cast(null as TEXT) as 
    
    kzear
    
 , 
    cast(null as TEXT) as 
    
    kzstr
    
 , 
    cast(null as TEXT) as 
    
    kzvbr
    
 , 
    cast(null as TEXT) as 
    
    kzzug
    
 , 
    cast(null as TEXT) as 
    
    lbbsa_cid
    
 , 
    cast(null as TEXT) as 
    
    lbbsa_sid
    
 , 
    cast(null as numeric(28,6)) as 
    
    lbkum
    
 , 
    cast(null as TEXT) as 
    
    le_vbeln
    
 , 
    cast(null as TEXT) as 
    
    lfbja
    
 , 
    cast(null as TEXT) as 
    
    lfbnr
    
 , 
    cast(null as TEXT) as 
    
    lfpos
    
 , 
    cast(null as TEXT) as 
    
    lgnum
    
 , 
    cast(null as TEXT) as 
    
    lgort
    
 , 
    cast(null as TEXT) as 
    
    lgort_cid
    
 , 
    cast(null as TEXT) as 
    
    lgort_sid
    
 , 
    cast(null as TEXT) as 
    
    lgpla
    
 , 
    cast(null as TEXT) as 
    
    lgtyp
    
 , 
    cast(null as TEXT) as 
    
    lifnr
    
 , 
    cast(null as TEXT) as 
    
    lifnr_cid
    
 , 
    cast(null as TEXT) as 
    
    lifnr_sid
    
 , 
    cast(null as TEXT) as 
    
    line_depth
    
 , 
    cast(null as TEXT) as 
    
    line_id
    
 , 
    cast(null as TEXT) as 
    
    llief
    
 , 
    cast(null as TEXT) as 
    
    lmbmv
    
 , 
    cast(null as TEXT) as 
    
    lsmeh
    
 , 
    cast(null as numeric(28,6)) as 
    
    lsmng
    
 , 
    cast(null as TEXT) as 
    
    lstar
    
 , 
    cast(null as TEXT) as 
    
    maa_urzei
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mat_kdauf
    
 , 
    cast(null as TEXT) as 
    
    mat_kdauf_cid
    
 , 
    cast(null as TEXT) as 
    
    mat_kdpos
    
 , 
    cast(null as TEXT) as 
    
    mat_kdpos_cid
    
 , 
    cast(null as TEXT) as 
    
    mat_pspnr
    
 , 
    cast(null as TEXT) as 
    
    mat_pspnr_cid
    
 , 
    cast(null as TEXT) as 
    
    matbf
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as TEXT) as 
    
    mblnr
    
 , 
    cast(null as TEXT) as 
    
    meins
    
 , 
    cast(null as numeric(28,6)) as 
    
    menge
    
 , 
    cast(null as TEXT) as 
    
    mengu
    
 , 
    cast(null as TEXT) as 
    
    mjahr
    
 , 
    cast(null as TEXT) as 
    
    month_budat
    
 , 
    cast(null as TEXT) as 
    
    msr_active
    
 , 
    cast(null as TEXT) as 
    
    mwskz
    
 , 
    cast(null as TEXT) as 
    
    nplnr
    
 , 
    cast(null as TEXT) as 
    
    nroflabels
    
 , 
    cast(null as TEXT) as 
    
    nschn
    
 , 
    cast(null as TEXT) as 
    
    oicondcod
    
 , 
    cast(null as numeric(28,6)) as 
    
    oinavnw
    
 , 
    cast(null as numeric(28,6)) as 
    
    pabpm
    
 , 
    cast(null as numeric(28,6)) as 
    
    palan
    
 , 
    cast(null as TEXT) as 
    
    paobjnr
    
 , 
    cast(null as TEXT) as 
    
    parbu
    
 , 
    cast(null as TEXT) as 
    
    parent_id
    
 , 
    cast(null as TEXT) as 
    
    pargb
    
 , 
    cast(null as numeric(28,6)) as 
    
    pbamg
    
 , 
    cast(null as TEXT) as 
    
    periv
    
 , 
    cast(null as TEXT) as 
    
    pernr
    
 , 
    cast(null as TEXT) as 
    
    plpla
    
 , 
    cast(null as TEXT) as 
    
    popup_mark
    
 , 
    cast(null as TEXT) as 
    
    pprctr
    
 , 
    cast(null as TEXT) as 
    
    prctr
    
 , 
    cast(null as numeric(28,6)) as 
    
    price_a1
    
 , 
    cast(null as TEXT) as 
    
    price_source_a1
    
 , 
    cast(null as TEXT) as 
    
    projn
    
 , 
    cast(null as TEXT) as 
    
    prznr
    
 , 
    cast(null as TEXT) as 
    
    ps_psp_pnr
    
 , 
    cast(null as TEXT) as 
    
    qinspst
    
 , 
    cast(null as TEXT) as 
    
    quarter_budat
    
 , 
    cast(null as TEXT) as 
    
    record_type
    
 , 
    cast(null as TEXT) as 
    
    resourcename_cid
    
 , 
    cast(null as TEXT) as 
    
    resourcename_sid
    
 , 
    cast(null as TEXT) as 
    
    reversal_movement
    
 , 
    cast(null as TEXT) as 
    
    rsart
    
 , 
    cast(null as TEXT) as 
    
    rsnum
    
 , 
    cast(null as TEXT) as 
    
    rspos
    
 , 
    cast(null as TEXT) as 
    
    sakto
    
 , 
    cast(null as numeric(28,6)) as 
    
    salk3
    
 , 
    cast(null as TEXT) as 
    
    service_doc_id
    
 , 
    cast(null as TEXT) as 
    
    service_doc_item_id
    
 , 
    cast(null as TEXT) as 
    
    service_doc_type
    
 , 
    cast(null as TEXT) as 
    
    serviceperformer
    
 , 
    cast(null as TEXT) as 
    
    sgt_rcat
    
 , 
    cast(null as TEXT) as 
    
    sgt_scat
    
 , 
    cast(null as TEXT) as 
    
    sgt_umscat
    
 , 
    cast(null as TEXT) as 
    
    sgtxt
    
 , 
    cast(null as TEXT) as 
    
    shkum
    
 , 
    cast(null as TEXT) as 
    
    shkzg
    
 , 
    cast(null as TEXT) as 
    
    sjahr
    
 , 
    cast(null as TEXT) as 
    
    smbln
    
 , 
    cast(null as TEXT) as 
    
    smblp
    
 , 
    cast(null as TEXT) as 
    
    sobkz
    
 , 
    cast(null as TEXT) as 
    
    spe_budat_uhr
    
 , 
    cast(null as TEXT) as 
    
    spe_budat_zone
    
 , 
    cast(null as TEXT) as 
    
    spe_gts_stock_ty
    
 , 
    cast(null as TEXT) as 
    
    spe_logsys
    
 , 
    cast(null as TEXT) as 
    
    spe_mdnum_ewm
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_qty
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_value_a1
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_vkwrt
    
 , 
    cast(null as TEXT) as 
    
    tanum
    
 , 
    cast(null as TEXT) as 
    
    tbnum
    
 , 
    cast(null as TEXT) as 
    
    tbpos
    
 , 
    cast(null as TEXT) as 
    
    tbpri
    
 , 
    cast(null as TEXT) as 
    
    tcode
    
 , 
    cast(null as TEXT) as 
    
    tcode2
    
 , 
    cast(null as TEXT) as 
    
    txjcd
    
 , 
    cast(null as TEXT) as 
    
    ubnum
    
 , 
    cast(null as TEXT) as 
    
    umbar
    
 , 
    cast(null as TEXT) as 
    
    umbuk_cg
    
 , 
    cast(null as TEXT) as 
    
    umcha
    
 , 
    cast(null as TEXT) as 
    
    umkzbws_cg
    
 , 
    cast(null as TEXT) as 
    
    umlgo
    
 , 
    cast(null as TEXT) as 
    
    ummab
    
 , 
    cast(null as TEXT) as 
    
    ummab_cid
    
 , 
    cast(null as TEXT) as 
    
    ummat
    
 , 
    cast(null as TEXT) as 
    
    ummen_cg
    
 , 
    cast(null as TEXT) as 
    
    umsok
    
 , 
    cast(null as TEXT) as 
    
    umsok_cid
    
 , 
    cast(null as TEXT) as 
    
    umwer_cg
    
 , 
    cast(null as TEXT) as 
    
    umwrk
    
 , 
    cast(null as TEXT) as 
    
    umwrk_cid
    
 , 
    cast(null as TEXT) as 
    
    umzst
    
 , 
    cast(null as TEXT) as 
    
    umzus
    
 , 
    cast(null as TEXT) as 
    
    urzei
    
 , 
    cast(null as TEXT) as 
    
    usnam
    
 , 
    cast(null as TEXT) as 
    
    vbeln_im
    
 , 
    cast(null as TEXT) as 
    
    vbelp_im
    
 , 
    cast(null as TEXT) as 
    
    vbobj_cg
    
 , 
    cast(null as TEXT) as 
    
    vbobj_sg
    
 , 
    cast(null as date) as 
    
    vfdat
    
 , 
    cast(null as TEXT) as 
    
    vgart
    
 , 
    cast(null as TEXT) as 
    
    vkmws
    
 , 
    cast(null as numeric(28,6)) as 
    
    vkwra
    
 , 
    cast(null as numeric(28,6)) as 
    
    vkwrt
    
 , 
    cast(null as TEXT) as 
    
    vprsv
    
 , 
    cast(null as TEXT) as 
    
    vptnr
    
 , 
    cast(null as TEXT) as 
    
    vschn
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as TEXT) as 
    
    weanz
    
 , 
    cast(null as TEXT) as 
    
    week_budat
    
 , 
    cast(null as TEXT) as 
    
    weekday_budat
    
 , 
    cast(null as TEXT) as 
    
    wempf
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    wertu
    
 , 
    cast(null as TEXT) as 
    
    weunb
    
 , 
    cast(null as TEXT) as 
    
    wever
    
 , 
    cast(null as TEXT) as 
    
    work_item_id
    
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
    
    xabln
    
 , 
    cast(null as TEXT) as 
    
    xauto
    
 , 
    cast(null as TEXT) as 
    
    xbeau
    
 , 
    cast(null as TEXT) as 
    
    xblnr
    
 , 
    cast(null as TEXT) as 
    
    xblvs
    
 , 
    cast(null as TEXT) as 
    
    xcompl
    
 , 
    cast(null as TEXT) as 
    
    xfmat
    
 , 
    cast(null as TEXT) as 
    
    xmacc
    
 , 
    cast(null as TEXT) as 
    
    xobew
    
 , 
    cast(null as TEXT) as 
    
    xprint
    
 , 
    cast(null as TEXT) as 
    
    xruej
    
 , 
    cast(null as TEXT) as 
    
    xruem
    
 , 
    cast(null as TEXT) as 
    
    xsauf
    
 , 
    cast(null as TEXT) as 
    
    xsaut
    
 , 
    cast(null as TEXT) as 
    
    xserg
    
 , 
    cast(null as TEXT) as 
    
    xskst
    
 , 
    cast(null as TEXT) as 
    
    xspro
    
 , 
    cast(null as TEXT) as 
    
    xstor
    
 , 
    cast(null as TEXT) as 
    
    xwoff
    
 , 
    cast(null as TEXT) as 
    
    xwsbr
    
 , 
    cast(null as TEXT) as 
    
    year_budat
    
 , 
    cast(null as TEXT) as 
    
    yearday_budat
    
 , 
    cast(null as TEXT) as 
    
    yearmonth_budat
    
 , 
    cast(null as TEXT) as 
    
    yearquarter_budat
    
 , 
    cast(null as TEXT) as 
    
    yearweek_budat
    
 , 
    cast(null as TEXT) as 
    
    zeile
    
 , 
    cast(null as TEXT) as 
    
    zekkn
    
 , 
    cast(null as TEXT) as 
    
    zusch
    
 , 
    cast(null as TEXT) as 
    
    zustd
    
 , 
    cast(null as TEXT) as 
    
    zustd_t156m
    
 


    from base
),

final as (
    select
        mandt,                
        mblnr,                
        mjahr,                
        zeile,                
        line_id,              
        parent_id,            
        line_depth,           
        maa_urzei,            
        bwart,                
        xauto,                
        matnr,                
        werks,                
        lgort,                
        charg,                
        insmk,                
        zusch,                
        zustd,                
        sobkz,                
        lifnr,                
        kunnr,                
        kdauf,                
        kdpos,                
        kdein,  
        plpla,  
        shkzg,  
        waers,  
        dmbtr,  
        bnbtr,  
        bualt,  
        shkum,  
        dmbum,  
        bwtar,  
        menge,  
        meins,  
        erfmg,  
        erfme,  
        bpmng,  
        bprme,  
        ebeln,  
        ebelp,  
        lfbja,  
        lfbnr,  
        lfpos,  
        sjahr,  
        smbln,  
        smblp,  
        elikz,  
        sgtxt,   
        equnr,   
        wempf,   
        ablad,   
        gsber,   
        kokrs,   
        pargb,   
        parbu,   
        kostl,   
        projn,   
        aufnr,   
        anln1,   
        anln2,   
        xskst,   
        xsauf,   
        xspro,   
        xserg,   
        gjahr,   
        xruem,   
        xruej,   
        bukrs,   
        belnr,   
        buzei,   
        belum,   
        buzum,   
        rsnum,   
        rspos,   
        kzear,   
        pbamg,   
        kzstr,   
        ummat,   
        umwrk,   
        umlgo,   
        umcha,   
        umzst,   
        umzus,   
        umbar,   
        umsok,   
        kzbew,   
        kzvbr,   
        kzzug,   
        weunb,   
        palan,   
        lgnum,   
        lgtyp,   
        lgpla,   
        bestq,   
        bwlvs,   
        tbnum,   
        tbpos,   
        xblvs,       
        vschn,       
        nschn,       
        dypla,       
        ubnum,       
        tbpri,       
        tanum,       
        weanz,       
        grund,       
        evers,       
        evere,       
        imkey,       
        kstrg,       
        paobjnr,     
        prctr,       
        ps_psp_pnr,  
        nplnr,       
        aufpl,       
        aplzl,       
        aufps,       
        vptnr,       
        fipos,       
        sakto,       
        bstmg,       
        bstme,       
        xwsbr,                
        emlif,                
        dummy_incl_eew_cobl,  
        exbwr,                
        vkwrt,                
        aktnr,                
        zekkn,                
        vfdat,                
        cuobj_ch,             
        exvkw,                
        pprctr,               
        rsart,                
        geber,                
        fistl,                
        matbf,                
        ummab,                
        bustm,                
        bustw,                
        mengu,                
        wertu,                
        lbkum,                
        salk3,                
        vprsv,                
        fkber,                
        dabrbz,     
        vkwra,      
        dabrz,      
        xbeau,      
        lsmng,      
        lsmeh,      
        kzbws,      
        qinspst,    
        urzei,      
        j_1bexbase, 
        mwskz,      
        txjcd,      
        ematn,      
        j_1agirupd, 
        vkmws,      
        hsdat,      
        berkz,      
        mat_kdauf,  
        mat_kdpos,  
        mat_pspnr,  
        xwoff,      
        bemot,      
        prznr,      
        llief,      
        lstar,                   
        xobew,                   
        grant_nbr,               
        zustd_t156m,             
        spe_gts_stock_ty,        
        kblnr,                   
        kblpos,                  
        xmacc,                   
        vgart as vgart_mkpf,   
        budat as budat_mkpf,   
        cpudt as cpudt_mkpf,   
        cputm as cputm_mkpf,   
        usnam as usnam_mkpf,   
        xblnr as xblnr_mkpf,   
        tcode2 as tcode2_mkpf, 
        vbeln_im,                
        vbelp_im,                
        sgt_scat,                
        sgt_umscat,              
        sgt_rcat,                
        serviceperformer,        
        pernr,                   
        knttp_gr,                
        work_item_id,            
        fbuda,                   
        xprint,                   
        nroflabels,               
        _cwm_menge,               
        _cwm_meins,               
        _cwm_erfmg,               
        _cwm_erfme,               
        service_doc_type,         
        service_doc_id,           
        service_doc_item_id,      
        ewm_lgnum,                
        ewm_gmdoc,                
        resourcename_sid,         
        resourcename_cid,         
        dummy_matdoc_incl_eew_ps, 
        disub_owner,              
        fsh_season_year,          
        fsh_season,               
        fsh_collection,           
        fsh_theme,                
        '' as fsh_umsea_yr,               
        '' as fsh_umsea,                  
        '' as fsh_umcoll,                 
        '' as fsh_umtheme,                
        '' as sgt_chint,                  
        compl_mark,            
        fzgls_mark,            
        etanp_mark,            
        popup_mark,            
        oinavnw,               
        oicondcod,             
        condi,                 
        wrf_charstc1,          
        wrf_charstc2,          
        wrf_charstc3,
        vgart,	
        blart,	
        blaum,	
        bldat,	
        budat,	
        cpudt,	
        cputm,	
        aedat,	
        usnam,	
        tcode,	
        xblnr,	
        bktxt,	
        frath,	
        frbnr,	
        wever,
        xabln,	
        awsys,	
        bla2d,	
        tcode2,	
        bfwms,	
        exnum,	
        spe_budat_uhr,	
        spe_budat_zone,	
        le_vbeln,	
        spe_logsys,	
        spe_mdnum_ewm,	
        gts_cusref_no,	
        fls_rsto,	
        msr_active,	
        knumv,	
        xcompl,
        cast(record_type as TEXT) as record_type,
        cast(header_counter as numeric(28,6)) as header_counter
    from fields
)

select *
from final
