with base as (

    select 
    from "sap"."main_sap"."stg_sap__cosp_bak_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as TEXT) as 
    
    beknz
    
 , 
    cast(null as TEXT) as 
    
    gjahr
    
 , 
    cast(null as TEXT) as 
    
    hrkft
    
 , 
    cast(null as TEXT) as 
    
    kstar
    
 , 
    cast(null as TEXT) as 
    
    lednr
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    objnr
    
 , 
    cast(null as TEXT) as 
    
    pargb
    
 , 
    cast(null as TEXT) as 
    
    perbl
    
 , 
    cast(null as TEXT) as 
    
    twaer
    
 , 
    cast(null as TEXT) as 
    
    vbund
    
 , 
    cast(null as TEXT) as 
    
    versn
    
 , 
    cast(null as TEXT) as 
    
    vrgng
    
 , 
    cast(null as TEXT) as 
    
    wrttp
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg011
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf004
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag001
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog012
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg001
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg014
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg009
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog002
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf013
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag010
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg010
    
 , 
    cast(null as TEXT) as 
    
    muv007
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef008
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg004
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf003
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog011
    
 , 
    cast(null as TEXT) as 
    
    muv016
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg013
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg008
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog001
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf012
    
 , 
    cast(null as TEXT) as 
    
    muv006
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg003
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef007
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf002
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog010
    
 , 
    cast(null as TEXT) as 
    
    muv015
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg012
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef016
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg007
    
 , 
    cast(null as TEXT) as 
    
    beltp
    
 , 
    cast(null as numeric(28,6)) as 
    
    timestmp
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf011
    
 , 
    cast(null as TEXT) as 
    
    muv005
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg002
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef006
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf001
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg016
    
 , 
    cast(null as TEXT) as 
    
    muv014
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg011
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef015
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg006
    
 , 
    cast(null as TEXT) as 
    
    segment
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf010
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg009
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag009
    
 , 
    cast(null as TEXT) as 
    
    muv004
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef005
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg001
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg015
    
 , 
    cast(null as TEXT) as 
    
    muv013
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef014
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg010
    
 , 
    cast(null as TEXT) as 
    
    meinh
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg005
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg008
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag008
    
 , 
    cast(null as TEXT) as 
    
    muv003
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef004
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog009
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg014
    
 , 
    cast(null as TEXT) as 
    
    muv012
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef013
    
 , 
    cast(null as TEXT) as 
    
    budget_pd
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg004
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg007
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag007
    
 , 
    cast(null as TEXT) as 
    
    muv002
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef003
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog008
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg013
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag016
    
 , 
    cast(null as TEXT) as 
    
    muv011
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef012
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg016
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg003
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag006
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf009
    
 , 
    cast(null as TEXT) as 
    
    fkber
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg006
    
 , 
    cast(null as TEXT) as 
    
    muv001
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef002
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog007
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg012
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag015
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg009
    
 , 
    cast(null as TEXT) as 
    
    muv010
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef011
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg015
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg002
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag005
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf008
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog016
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg005
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef001
    
 , 
    cast(null as TEXT) as 
    
    geber
    
 , 
    cast(null as TEXT) as 
    
    grant_nbr
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog006
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg011
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg008
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag014
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef010
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg014
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf007
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg004
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg001
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag004
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog015
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog005
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf016
    
 , 
    cast(null as numeric(28,6)) as 
    
    meg010
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag013
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg007
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg013
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf006
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag003
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg003
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog014
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg016
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog004
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf015
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag012
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg006
    
 , 
    cast(null as TEXT) as 
    
    muv009
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg012
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf005
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag002
    
 , 
    cast(null as numeric(28,6)) as 
    
    wtg002
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog013
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg015
    
 , 
    cast(null as numeric(28,6)) as 
    
    wog003
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkf014
    
 , 
    cast(null as numeric(28,6)) as 
    
    pag011
    
 , 
    cast(null as numeric(28,6)) as 
    
    mef009
    
 , 
    cast(null as TEXT) as 
    
    muv008
    
 , 
    cast(null as numeric(28,6)) as 
    
    wkg005
    
 


    from base
),

final as (

    select
        cast(beknz as TEXT) as beknz,
        cast(gjahr as TEXT) as gjahr,
        cast(hrkft as TEXT) as hrkft,
        cast(kstar as TEXT) as kstar,
        cast(lednr as TEXT) as lednr,
        cast(mandt as TEXT) as mandt,
        cast(objnr as TEXT) as objnr,
        cast(pargb as TEXT) as pargb,
        cast(perbl as TEXT) as perbl,
        cast(twaer as TEXT) as twaer,
        cast(vbund as TEXT) as vbund,
        cast(versn as TEXT) as versn,
        cast(vrgng as TEXT) as vrgng,
        cast(wrttp as TEXT) as wrttp,
        wtg001,
        wtg002,
        wtg003,
        wtg004,
        wtg005,
        wtg006,
        wtg007,
        wtg008,
        wtg009,
        wtg010,
        wtg011,
        wtg012,
        wtg013,
        wtg014,
        wtg015,
        wtg016,
        wog001,
        wog002,
        wog003,
        wog004,
        wog005,
        wog006,
        wog007,
        wog008,
        wog009,
        wog010,
        wog011,
        wog012,
        wog013,
        wog014,
        wog015,
        wog016,
        wkg001,
        wkg002,
        wkg003,
        wkg004,
        wkg005,
        wkg006,
        wkg007,
        wkg008,
        wkg009,
        wkg010,
        wkg011,
        wkg012,
        wkg013,
        wkg014,
        wkg015,
        wkg016,
        wkf001,
        wkf002,
        wkf003,
        wkf004,
        wkf005,
        wkf006,
        wkf007,
        wkf008,
        wkf009,
        wkf010,
        wkf011,
        wkf012,
        wkf013,
        wkf014,
        wkf015,
        wkf016,
        pag001,
        pag002,
        pag003,
        pag004,
        pag005,
        pag006,
        pag007,
        pag008,
        pag009,
        pag010,
        pag011,
        pag012,
        pag013,
        pag014,
        pag015,
        pag016,
        meg001,
        meg002,
        meg003,
        meg004,
        meg005,
        meg006,
        meg007,
        meg008,
        meg009,
        meg010,
        meg011,
        meg012,
        meg013,
        meg014,
        meg015,
        meg016,
        mef001,
        mef002,
        mef003,
        mef004,
        mef005,
        mef006,
        mef007,
        mef008,
        mef009,
        mef010,
        mef011,
        mef012,
        mef013,
        mef014,
        mef015,
        mef016,
        cast(muv001 as TEXT) as muv001,
        cast(muv002 as TEXT) as muv002,
        cast(muv003 as TEXT) as muv003,
        cast(muv004 as TEXT) as muv004,
        cast(muv005 as TEXT) as muv005,
        cast(muv006 as TEXT) as muv006,
        cast(muv007 as TEXT) as muv007,
        cast(muv008 as TEXT) as muv008,
        cast(muv009 as TEXT) as muv009,
        cast(muv010 as TEXT) as muv010,
        cast(muv011 as TEXT) as muv011,
        cast(muv012 as TEXT) as muv012,
        cast(muv013 as TEXT) as muv013,
        cast(muv014 as TEXT) as muv014,
        cast(muv015 as TEXT) as muv015,
        cast(muv016 as TEXT) as muv016,
        cast(beltp as TEXT) as beltp,
        timestmp,
        cast(bukrs as TEXT) as bukrs,
        cast(fkber as TEXT) as fkber,
        cast(segment as TEXT) as segment,
        cast(geber as TEXT) as geber,
        cast(grant_nbr as TEXT) as grant_nbr,
        cast(budget_pd as TEXT) as budget_pd,
        cast(meinh as TEXT) as meinh,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived

    from fields

)

select * from final
