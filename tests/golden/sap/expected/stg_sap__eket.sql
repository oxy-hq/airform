with base as (
    select 
    from "sap"."main_sap"."stg_sap__eket_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    abart
    
 , 
    cast(null as TEXT) as 
    
    altdt
    
 , 
    cast(null as TEXT) as 
    
    ameng
    
 , 
    cast(null as TEXT) as 
    
    anzsn
    
 , 
    cast(null as TEXT) as 
    
    aulwe
    
 , 
    cast(null as TEXT) as 
    
    banfn
    
 , 
    cast(null as TEXT) as 
    
    bedat
    
 , 
    cast(null as TEXT) as 
    
    bnfpo
    
 , 
    cast(null as TEXT) as 
    
    budg_type
    
 , 
    cast(null as TEXT) as 
    
    cd_locno
    
 , 
    cast(null as TEXT) as 
    
    cd_loctype
    
 , 
    cast(null as TEXT) as 
    
    charg
    
 , 
    cast(null as TEXT) as 
    
    check_type
    
 , 
    cast(null as TEXT) as 
    
    chkom
    
 , 
    cast(null as TEXT) as 
    
    cncl_ancmnt_done
    
 , 
    cast(null as TEXT) as 
    
    dat01
    
 , 
    cast(null as TEXT) as 
    
    dabmg
    
 , 
    cast(null as TEXT) as 
    
    dateshift_number
    
 , 
    cast(null as TEXT) as 
    
    dl_id
    
 , 
    cast(null as TEXT) as 
    
    dng_date
    
 , 
    cast(null as TEXT) as 
    
    dng_time
    
 , 
    cast(null as TEXT) as 
    
    ebeln
    
 , 
    cast(null as TEXT) as 
    
    ebelp
    
 , 
    cast(null as TEXT) as 
    
    eindt
    
 , 
    cast(null as TEXT) as 
    
    eldat
    
 , 
    cast(null as TEXT) as 
    
    eluhr
    
 , 
    cast(null as TEXT) as 
    
    estkz
    
 , 
    cast(null as TEXT) as 
    
    etenr
    
 , 
    cast(null as TEXT) as 
    
    fixkz
    
 , 
    cast(null as TEXT) as 
    
    fsh_os_id
    
 , 
    cast(null as TEXT) as 
    
    fsh_ralloc_qty
    
 , 
    cast(null as TEXT) as 
    
    fsh_salloc_qty
    
 , 
    cast(null as TEXT) as 
    
    geo_route
    
 , 
    cast(null as TEXT) as 
    
    glmng
    
 , 
    cast(null as TEXT) as 
    
    gts_ind
    
 , 
    cast(null as TEXT) as 
    
    handover_date
    
 , 
    cast(null as TEXT) as 
    
    handoverdate
    
 , 
    cast(null as TEXT) as 
    
    handovertime
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    key_id
    
 , 
    cast(null as TEXT) as 
    
    lddat
    
 , 
    cast(null as TEXT) as 
    
    lduhr
    
 , 
    cast(null as TEXT) as 
    
    licha
    
 , 
    cast(null as TEXT) as 
    
    lpein
    
 , 
    cast(null as TEXT) as 
    
    mahnz
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mbdat
    
 , 
    cast(null as TEXT) as 
    
    mbuhr
    
 , 
    cast(null as integer) as 
    
    menge
    
 , 
    cast(null as TEXT) as 
    
    mng02
    
 , 
    cast(null as TEXT) as 
    
    no_scem
    
 , 
    cast(null as TEXT) as 
    
    nodisp
    
 , 
    cast(null as TEXT) as 
    
    otb_curr
    
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
    
    qunum
    
 , 
    cast(null as TEXT) as 
    
    qupos
    
 , 
    cast(null as TEXT) as 
    
    route_gts
    
 , 
    cast(null as TEXT) as 
    
    rsnum
    
 , 
    cast(null as TEXT) as 
    
    sernr
    
 , 
    cast(null as TEXT) as 
    
    slfdt
    
 , 
    cast(null as TEXT) as 
    
    spr_rsn_profile
    
 , 
    cast(null as TEXT) as 
    
    tddat
    
 , 
    cast(null as TEXT) as 
    
    tduhr
    
 , 
    cast(null as TEXT) as 
    
    tsp
    
 , 
    cast(null as TEXT) as 
    
    uzeit
    
 , 
    cast(null as TEXT) as 
    
    verid
    
 , 
    cast(null as TEXT) as 
    
    wadat
    
 , 
    cast(null as TEXT) as 
    
    wamng
    
 , 
    cast(null as TEXT) as 
    
    wauhr
    
 , 
    cast(null as TEXT) as 
    
    wemng
    
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
        abart,
        altdt,
        ameng,
        anzsn,
        aulwe,
        banfn,
        bedat,
        bnfpo,
        budg_type,
        cd_locno,
        cd_loctype,
        charg,
        check_type,
        chkom,
        cncl_ancmnt_done,
        dabmg,
        dat01,
        dateshift_number,
        dl_id,
        dng_date,
        dng_time,
        cast(ebeln as TEXT) as ebeln,
        cast(ebelp as TEXT) as ebelp,
        eindt,
        eldat,
        eluhr,
        estkz,
        etenr,
        fixkz,
        fsh_os_id,
        fsh_ralloc_qty,
        fsh_salloc_qty,
        geo_route,
        glmng,
        gts_ind,
        handover_date,
        handoverdate,
        handovertime,
        hvr_change_time,
        hvr_is_deleted,
        key_id,
        lddat,
        lduhr,
        licha,
        lpein,
        mahnz,
        cast(mandt as TEXT) as mandt,
        mbdat,
        mbuhr,
        cast(menge as numeric(28,6)) as menge,
        mng02,
        no_scem,
        nodisp,
        otb_curr,
        otb_reason,
        otb_res_value,
        otb_spec_value,
        otb_status,
        otb_value,
        qunum,
        qupos,
        route_gts,
        rsnum,
        sernr,
        slfdt,
        spr_rsn_profile,
        tddat,
        tduhr,
        tsp,
        uzeit,
        verid,
        wadat,
        wamng,
        wauhr,
        wemng,
        _fivetran_sap_archived,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
