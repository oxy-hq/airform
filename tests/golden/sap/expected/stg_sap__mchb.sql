with base as (
    select 
    from "sap"."main_sap"."stg_sap__mchb_tmp"
),

fields as (
    select
        
    cast(null as numeric(28,6)) as 
    
    _cwm_ceinm
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cinsm
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_clabs
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cretm
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cspem
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cumlm
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cvmei
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cvmin
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cvmla
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cvmre
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cvmsp
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_cvmum
    
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
    
    aenam
    
 , 
    cast(null as numeric(28,6)) as 
    
    ceinm
    
 , 
    cast(null as TEXT) as 
    
    charg
    
 , 
    cast(null as date) as 
    
    chdll
    
 , 
    cast(null as TEXT) as 
    
    chjin
    
 , 
    cast(null as TEXT) as 
    
    chrue
    
 , 
    cast(null as numeric(28,6)) as 
    
    cinsm
    
 , 
    cast(null as numeric(28,6)) as 
    
    clabs
    
 , 
    cast(null as numeric(28,6)) as 
    
    cretm
    
 , 
    cast(null as numeric(28,6)) as 
    
    cspem
    
 , 
    cast(null as numeric(28,6)) as 
    
    cumlm
    
 , 
    cast(null as numeric(28,6)) as 
    
    cvmei
    
 , 
    cast(null as numeric(28,6)) as 
    
    cvmin
    
 , 
    cast(null as numeric(28,6)) as 
    
    cvmla
    
 , 
    cast(null as numeric(28,6)) as 
    
    cvmre
    
 , 
    cast(null as numeric(28,6)) as 
    
    cvmsp
    
 , 
    cast(null as numeric(28,6)) as 
    
    cvmum
    
 , 
    cast(null as TEXT) as 
    
    ernam
    
 , 
    cast(null as date) as 
    
    ersda
    
 , 
    cast(null as TEXT) as 
    
    fsh_collection
    
 , 
    cast(null as numeric(28,6)) as 
    
    fsh_salloc_qty
    
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
    
    herkl
    
 , 
    cast(null as TEXT) as 
    
    kzice
    
 , 
    cast(null as TEXT) as 
    
    kzicl
    
 , 
    cast(null as TEXT) as 
    
    kzicq
    
 , 
    cast(null as TEXT) as 
    
    kzics
    
 , 
    cast(null as TEXT) as 
    
    kzvce
    
 , 
    cast(null as TEXT) as 
    
    kzvcl
    
 , 
    cast(null as TEXT) as 
    
    kzvcq
    
 , 
    cast(null as TEXT) as 
    
    kzvcs
    
 , 
    cast(null as date) as 
    
    laeda
    
 , 
    cast(null as TEXT) as 
    
    lfgja
    
 , 
    cast(null as TEXT) as 
    
    lfmon
    
 , 
    cast(null as TEXT) as 
    
    lgort
    
 , 
    cast(null as TEXT) as 
    
    lvorm
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as TEXT) as 
    
    sgt_scat
    
 , 
    cast(null as TEXT) as 
    
    sperc
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 


    from base
),

final as (
    select
        _cwm_ceinm,
        _cwm_cinsm,
        _cwm_clabs,
        _cwm_cretm,
        _cwm_cspem,
        _cwm_cumlm,
        _cwm_cvmei,
        _cwm_cvmin,
        _cwm_cvmla,
        _cwm_cvmre,
        _cwm_cvmsp,
        _cwm_cvmum,
        _fivetran_deleted,
        _fivetran_sap_archived,
        _fivetran_synced,
        aenam,
        ceinm,
        cast(charg as TEXT) as charg,
        chdll,
        chjin,
        chrue,
        cinsm,
        clabs,
        cretm,
        cspem,
        cumlm,
        cvmei,
        cvmin,
        cvmla,
        cvmre,
        cvmsp,
        cvmum,
        ernam,
        ersda,
        fsh_collection,
        fsh_salloc_qty,
        fsh_season,
        fsh_season_year,
        fsh_theme,
        herkl,
        kzice,
        kzicl,
        kzicq,
        kzics,
        kzvce,
        kzvcl,
        kzvcq,
        kzvcs,
        laeda,
        cast(lfgja as TEXT) as lfgja,
        cast(lfmon as TEXT) as lfmon,
        cast(lgort as TEXT) as lgort,
        lvorm,
        cast(mandt as TEXT) as mandt,
        cast(matnr as TEXT) as matnr,
        sgt_scat,
        sperc,
        cast(werks as TEXT) as werks
    from fields
)

select *
from final
