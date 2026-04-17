with base as (
    select 
    from "sap"."main_sap"."stg_sap__ekbe_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    arewb
    
 , 
    cast(null as TEXT) as 
    
    arewr
    
 , 
    cast(null as TEXT) as 
    
    arewr_pop
    
 , 
    cast(null as TEXT) as 
    
    areww
    
 , 
    cast(null as TEXT) as 
    
    bamng
    
 , 
    cast(null as TEXT) as 
    
    bekkn
    
 , 
    cast(null as TEXT) as 
    
    belnr
    
 , 
    cast(null as TEXT) as 
    
    bewtp
    
 , 
    cast(null as TEXT) as 
    
    bldat
    
 , 
    cast(null as TEXT) as 
    
    bpmng
    
 , 
    cast(null as TEXT) as 
    
    bpmng_pop
    
 , 
    cast(null as TEXT) as 
    
    bpweb
    
 , 
    cast(null as TEXT) as 
    
    bpwes
    
 , 
    cast(null as TEXT) as 
    
    budat
    
 , 
    cast(null as TEXT) as 
    
    buzei
    
 , 
    cast(null as TEXT) as 
    
    bwart
    
 , 
    cast(null as TEXT) as 
    
    bwtar
    
 , 
    cast(null as TEXT) as 
    
    charg
    
 , 
    cast(null as TEXT) as 
    
    cpudt
    
 , 
    cast(null as TEXT) as 
    
    cputm
    
 , 
    cast(null as TEXT) as 
    
    dmbtr
    
 , 
    cast(null as TEXT) as 
    
    dmbtr_pop
    
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
    
    ernam
    
 , 
    cast(null as TEXT) as 
    
    et_upd
    
 , 
    cast(null as TEXT) as 
    
    etens
    
 , 
    cast(null as TEXT) as 
    
    evere
    
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
    
    gjahr
    
 , 
    cast(null as TEXT) as 
    
    grund
    
 , 
    cast(null as TEXT) as 
    
    hswae
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    introw
    
 , 
    cast(null as TEXT) as 
    
    inv_item_origin
    
 , 
    cast(null as TEXT) as 
    
    j_sc_die_comp_f
    
 , 
    cast(null as TEXT) as 
    
    knumv
    
 , 
    cast(null as TEXT) as 
    
    kudif
    
 , 
    cast(null as TEXT) as 
    
    lemin
    
 , 
    cast(null as TEXT) as 
    
    lfbnr
    
 , 
    cast(null as TEXT) as 
    
    lfgja
    
 , 
    cast(null as TEXT) as 
    
    lfpos
    
 , 
    cast(null as TEXT) as 
    
    lsmeh
    
 , 
    cast(null as TEXT) as 
    
    lsmng
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as integer) as 
    
    menge
    
 , 
    cast(null as TEXT) as 
    
    menge_pop
    
 , 
    cast(null as TEXT) as 
    
    mwskz
    
 , 
    cast(null as TEXT) as 
    
    packno
    
 , 
    cast(null as TEXT) as 
    
    reewr
    
 , 
    cast(null as TEXT) as 
    
    refwr
    
 , 
    cast(null as TEXT) as 
    
    retamt_fc
    
 , 
    cast(null as TEXT) as 
    
    retamt_lc
    
 , 
    cast(null as TEXT) as 
    
    retamtp_fc
    
 , 
    cast(null as TEXT) as 
    
    retamtp_lc
    
 , 
    cast(null as TEXT) as 
    
    rewrb
    
 , 
    cast(null as TEXT) as 
    
    saprl
    
 , 
    cast(null as TEXT) as 
    
    sgt_scat
    
 , 
    cast(null as TEXT) as 
    
    shkzg
    
 , 
    cast(null as TEXT) as 
    
    srvpos
    
 , 
    cast(null as TEXT) as 
    
    vbeln_st
    
 , 
    cast(null as TEXT) as 
    
    vbelp_st
    
 , 
    cast(null as TEXT) as 
    
    vgabe
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as TEXT) as 
    
    weora
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    wesbb
    
 , 
    cast(null as TEXT) as 
    
    wesbs
    
 , 
    cast(null as TEXT) as 
    
    wkurs
    
 , 
    cast(null as TEXT) as 
    
    wrbtr
    
 , 
    cast(null as TEXT) as 
    
    wrbtr_pop
    
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
    
    xblnr
    
 , 
    cast(null as TEXT) as 
    
    xmacc
    
 , 
    cast(null as TEXT) as 
    
    xunpl
    
 , 
    cast(null as TEXT) as 
    
    xwoff
    
 , 
    cast(null as TEXT) as 
    
    xwsbr
    
 , 
    cast(null as TEXT) as 
    
    zekkn
    
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
        arewb,
        arewr,
        arewr_pop,
        areww,
        bamng,
        bekkn,
        belnr,
        bewtp,
        bldat,
        bpmng,
        bpmng_pop,
        bpweb,
        bpwes,
        budat,
        buzei,
        bwart,
        bwtar,
        charg,
        cpudt,
        cputm,
        dmbtr,
        dmbtr_pop,
        cast(ebeln as TEXT) as ebeln,
        cast(ebelp as TEXT) as ebelp,
        elikz,
        ematn,
        ernam,
        et_upd,
        etens,
        evere,
        fsh_collection,
        fsh_season,
        fsh_season_year,
        fsh_theme,
        gjahr,
        grund,
        hswae,
        hvr_change_time,
        hvr_is_deleted,
        introw,
        inv_item_origin,
        j_sc_die_comp_f,
        knumv,
        kudif,
        lemin,
        lfbnr,
        lfgja,
        lfpos,
        lsmeh,
        lsmng,
        cast(mandt as TEXT) as mandt,
        cast(matnr as TEXT) as matnr,
        cast(menge as numeric(28,6)) as menge,
        menge_pop,
        mwskz,
        packno,
        reewr,
        refwr,
        retamt_fc,
        retamt_lc,
        retamtp_fc,
        retamtp_lc,
        rewrb,
        saprl,
        sgt_scat,
        cast(shkzg as TEXT) as shkzg,
        srvpos,
        vbeln_st,
        vbelp_st,
        cast(vgabe as TEXT) as vgabe,
        waers,
        weora,
        werks,
        wesbb,
        wesbs,
        wkurs,
        wrbtr,
        wrbtr_pop,
        wrf_charstc1,
        wrf_charstc2,
        wrf_charstc3,
        xblnr,
        xmacc,
        xunpl,
        xwoff,
        xwsbr,
        zekkn,
        _fivetran_sap_archived,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
