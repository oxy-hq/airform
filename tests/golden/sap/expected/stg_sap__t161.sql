with base as (

    select 
    from "sap"."main_sap"."stg_sap__t161_tmp"
),

fields as (

    select
        
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
    
    abgebot
    
 , 
    cast(null as TEXT) as 
    
    abvor
    
 , 
    cast(null as TEXT) as 
    
    ar_object
    
 , 
    cast(null as TEXT) as 
    
    brefn
    
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
    
    cp_aktive
    
 , 
    cast(null as TEXT) as 
    
    cptype
    
 , 
    cast(null as TEXT) as 
    
    fls_rsto
    
 , 
    cast(null as TEXT) as 
    
    fsh_dpr_detpro
    
 , 
    cast(null as TEXT) as 
    
    fsh_excl_return
    
 , 
    cast(null as TEXT) as 
    
    fsh_po_idoc
    
 , 
    cast(null as TEXT) as 
    
    fsh_var_kalsm
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_act
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_del
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_detdt
    
 , 
    cast(null as TEXT) as 
    
    fsh_vas_kalsm
    
 , 
    cast(null as TEXT) as 
    
    gsfrg
    
 , 
    cast(null as TEXT) as 
    
    hityp
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    koako
    
 , 
    cast(null as TEXT) as 
    
    koett
    
 , 
    cast(null as TEXT) as 
    
    kornr
    
 , 
    cast(null as TEXT) as 
    
    kzale
    
 , 
    cast(null as TEXT) as 
    
    lphis
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mill_omkz
    
 , 
    cast(null as TEXT) as 
    
    msr_active
    
 , 
    cast(null as TEXT) as 
    
    numka
    
 , 
    cast(null as TEXT) as 
    
    numkc
    
 , 
    cast(null as TEXT) as 
    
    numke
    
 , 
    cast(null as TEXT) as 
    
    numki
    
 , 
    cast(null as TEXT) as 
    
    oicsegi
    
 , 
    cast(null as TEXT) as 
    
    oirfqreq
    
 , 
    cast(null as TEXT) as 
    
    pargr
    
 , 
    cast(null as TEXT) as 
    
    pincr
    
 , 
    cast(null as TEXT) as 
    
    refba
    
 , 
    cast(null as TEXT) as 
    
    rdp_profile
    
 , 
    cast(null as TEXT) as 
    
    shenq
    
 , 
    cast(null as TEXT) as 
    
    stafo
    
 , 
    cast(null as TEXT) as 
    
    stako
    
 , 
    cast(null as TEXT) as 
    
    tolsl
    
 , 
    cast(null as TEXT) as 
    
    umlif
    
 , 
    cast(null as TEXT) as 
    
    upinc
    
 , 
    cast(null as TEXT) as 
    
    variante
    
 , 
    cast(null as TEXT) as 
    
    wrf_enable_dateline
    
 , 
    cast(null as TEXT) as 
    
    wvvkz
    
 , 
    cast(null as TEXT) as 
    
    xlokz
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_atnam
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_ceact
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_gauf
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_pdact
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_pprot
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_puser
    
 , 
    cast(null as TEXT) as 
    
    _sapmp_pausw
    
 


    from base
),

final as (
    select
        abgebot,
        abvor,
        ar_object,
        brefn,
        bsakz,
        bsart,
        bstyp,
        cp_aktive,
        cptype,
        fls_rsto,
        fsh_dpr_detpro,
        fsh_excl_return,
        fsh_po_idoc,
        fsh_var_kalsm,
        fsh_vas_act,
        fsh_vas_del,
        fsh_vas_detdt,
        fsh_vas_kalsm,
        gsfrg,
        hityp,
        hvr_change_time,
        hvr_is_deleted,
        koako,
        koett,
        kornr,
        kzale,
        lphis,
        cast(mandt as TEXT) as mandt,
        mill_omkz,
        msr_active,
        numka,
        numkc,
        numke,
        numki,
        oicsegi,
        oirfqreq,
        pargr,
        pincr,
        refba,
        rdp_profile,
        shenq,
        stafo,
        stako,
        tolsl,
        umlif,
        upinc,
        variante,
        wrf_enable_dateline,
        wvvkz,
        xlokz,
        _sapmp_atnam,
        _sapmp_ceact,
        _sapmp_gauf,
        _sapmp_pdact,
        _sapmp_pprot,
        _sapmp_puser,
        _sapmp_pausw,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_rowid
    from fields
)

select *
from final
