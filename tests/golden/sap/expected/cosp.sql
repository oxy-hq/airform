-- COSP compatibility view combining archived COSP_BAK data with derived ACDOCA data
-- This view replicates the SAP COSP table structure for cost object line items

with __dbt__cte__int_cosp__acdoca_base as (
-- First step of ACDOCA transformation for COSP compatibility
-- Joins ACDOCA with configuration tables and applies initial transformations

with acdoca_base as (

    select
        a.rclnt as mandt,
        cast('00' as VARCHAR) as lednr,
        a.objnr,
        a.ryear as gjahr,
        case
            when cast(a.accasty as VARCHAR) != '' then cast('04' as VARCHAR)
            else cast('11' as VARCHAR)
        end as wrttp,
        v.versn,
        a.racct as kstar,
        a.hrkft,
        a.vrgng,
        a.rassc as vbund,
        a.sbusa as pargb,
        a.co_beknz as beknz,
        a.rwcur as twaer,
        -- Dynamic BUZEI field selection based on configuration
        case
            when v.field_name_buzei = 'CO_BUZEI' then a.co_buzei
            when v.field_name_buzei = 'CO_BUZEI1' then a.co_buzei1
            when v.field_name_buzei = 'CO_BUZEI2' then a.co_buzei2
            when v.field_name_buzei = 'CO_BUZEI5' then a.co_buzei5
            when v.field_name_buzei = 'CO_BUZEI6' then a.co_buzei6
            when v.field_name_buzei = 'CO_BUZEI7' then a.co_buzei7
            else a.co_buzei
        end as buzei,
        a.rldnr,
        a.poper as perio,
        a.co_meinh as meinh,
        -- Dynamic WTGBTR calculations
        case
            when v.field_name_wtgbtr_add = 'WSL' then a.wsl
            when v.field_name_wtgbtr_add = 'WSL2' then a.wsl2
            when v.field_name_wtgbtr_add = 'WSL3' then a.wsl3
            else 0
        end as wtgbtr_add,
        case
            when v.field_name_wtgbtr_subtract = 'WSL' then a.wsl
            when v.field_name_wtgbtr_subtract = 'WSL2' then a.wsl2
            when v.field_name_wtgbtr_subtract = 'WSL3' then a.wsl3
            else 0
        end as wtgbtr_subtract,
        -- Dynamic WOGBTR calculations
        case
            when cast(v.set_to_zero as VARCHAR) = 'X' then 0
            when v.field_name_wogbtr_add = 'CO_OSL' then a.co_osl
            when v.field_name_wogbtr_add = 'HSL' then a.hsl
            when v.field_name_wogbtr_add = 'OSL' then a.osl
            when v.field_name_wogbtr_add = 'VSL' then a.vsl
            when v.field_name_wogbtr_add = 'BSL' then a.bsl
            when v.field_name_wogbtr_add = 'CSL' then a.csl
            when v.field_name_wogbtr_add = 'DSL' then a.dsl
            when v.field_name_wogbtr_add = 'ESL' then a.esl
            when v.field_name_wogbtr_add = 'FSL' then a.fsl
            when v.field_name_wogbtr_add = 'GSL' then a.gsl
            when v.field_name_wogbtr_add = 'KSL' then a.ksl
            else 0
        end as wogbtr_add,
        case
            when v.field_name_wogbtr_subtract = 'HSL' then a.hsl
            when v.field_name_wogbtr_subtract = 'OSL' then a.osl
            when v.field_name_wogbtr_subtract = 'CO_OSL' then a.co_osl
            when v.field_name_wogbtr_subtract = 'VSL' then a.vsl
            when v.field_name_wogbtr_subtract = 'BSL' then a.bsl
            when v.field_name_wogbtr_subtract = 'CSL' then a.csl
            when v.field_name_wogbtr_subtract = 'DSL' then a.dsl
            when v.field_name_wogbtr_subtract = 'ESL' then a.esl
            when v.field_name_wogbtr_subtract = 'FSL' then a.fsl
            when v.field_name_wogbtr_subtract = 'GSL' then a.gsl
            when v.field_name_wogbtr_subtract = 'KSL' then a.ksl
            else 0
        end as wogbtr_subtract,
        -- Dynamic WKGBTR calculations
        case
            when v.field_name_wkgbtr_add = 'KSL' then a.ksl
            when v.field_name_wkgbtr_add = 'OSL' then a.osl
            when v.field_name_wkgbtr_add = 'VSL' then a.vsl
            when v.field_name_wkgbtr_add = 'BSL' then a.bsl
            when v.field_name_wkgbtr_add = 'CSL' then a.csl
            when v.field_name_wkgbtr_add = 'DSL' then a.dsl
            when v.field_name_wkgbtr_add = 'ESL' then a.esl
            when v.field_name_wkgbtr_add = 'FSL' then a.fsl
            when v.field_name_wkgbtr_add = 'GSL' then a.gsl
            when v.field_name_wkgbtr_add = 'HSL' then a.hsl
            else 0
        end as wkgbtr_add,
        case
            when v.field_name_wkgbtr_subtract = 'KSL' then a.ksl
            when v.field_name_wkgbtr_subtract = 'OSL' then a.osl
            when v.field_name_wkgbtr_subtract = 'VSL' then a.vsl
            when v.field_name_wkgbtr_subtract = 'BSL' then a.bsl
            when v.field_name_wkgbtr_subtract = 'CSL' then a.csl
            when v.field_name_wkgbtr_subtract = 'DSL' then a.dsl
            when v.field_name_wkgbtr_subtract = 'ESL' then a.esl
            when v.field_name_wkgbtr_subtract = 'FSL' then a.fsl
            when v.field_name_wkgbtr_subtract = 'GSL' then a.gsl
            when v.field_name_wkgbtr_subtract = 'HSL' then a.hsl
            else 0
        end as wkgbtr_subtract,
        -- Dynamic WKFBTR calculations
        case
            when v.field_name_wkfbtr_add = 'KFSL' then a.kfsl
            when v.field_name_wkfbtr_add = 'KFSL2' then a.kfsl2
            when v.field_name_wkfbtr_add = 'KFSL3' then a.kfsl3
            else 0
        end as wkfbtr_add,
        case
            when v.field_name_wkfbtr_subtract = 'KFSL' then a.kfsl
            when v.field_name_wkfbtr_subtract = 'KFSL2' then a.kfsl2
            when v.field_name_wkfbtr_subtract = 'KFSL3' then a.kfsl3
            else 0
        end as wkfbtr_subtract,
        -- Dynamic PAGBTR calculations
        case
            when v.field_name_pagbtr_add = 'PSL' then a.psl
            when v.field_name_pagbtr_add = 'PSL2' then a.psl2
            when v.field_name_pagbtr_add = 'PSL3' then a.psl3
            else 0
        end as pagbtr_add,
        case
            when v.field_name_pagbtr_subtract = 'PSL' then a.psl
            when v.field_name_pagbtr_subtract = 'PSL2' then a.psl2
            when v.field_name_pagbtr_subtract = 'PSL3' then a.psl3
            else 0
        end as pagbtr_subtract,
        -- Quantity and manual update fields
        case
            when cast(v.versn as VARCHAR) != '000' or cast(v.set_to_zero as VARCHAR) = 'X' then 0
            else a.co_megbtr
        end as megbtr,
        case
            when cast(v.versn as VARCHAR) != '000' or cast(v.set_to_zero as VARCHAR) = 'X' then 0
            else a.co_mefbtr
        end as mefbtr,
        case
            when cast(v.versn as VARCHAR) != '000' or cast(v.set_to_zero as VARCHAR) = 'X' then 0
            else a.msl
        end as mbgbtr,
        case
            when cast(v.versn as VARCHAR) != '000' or cast(v.set_to_zero as VARCHAR) = 'X' then 0
            else a.mfsl
        end as mbfbtr,
        cast(a.muvflg as INTEGER) as muvflg,
        a.beltp,
        a.rbukrs as bukrs,
        a.rfarea as fkber,
        a.segment,
        a.rfund as geber,
        a.rgrant_nbr as grant_nbr,
        a.rbudget_pd as budget_pd,
        a.timestamp_at

    from main_sap.stg_sap__acdoca as a
    inner join main_sap.stg_sap__finsc_cmp_versnd as v
        on cast(v.mandt as VARCHAR) = cast(a.rclnt as VARCHAR)
        and cast(v.bukrs as VARCHAR) = cast(a.rbukrs as VARCHAR)
        and cast(v.rldnr as VARCHAR) = cast(a.rldnr as VARCHAR)
    inner join main_sap.stg_sap__tj01 as t
        on cast(t.vrgng as VARCHAR) = cast(a.vrgng as VARCHAR)
        and cast(t.xcosp as VARCHAR) = 'X'
        and (cast(t.xcoss as VARCHAR) = '' or t.xcoss is null)
    inner join main_sap.stg_sap__tka01 as tk
        on cast(tk.mandt as VARCHAR) = cast(a.rclnt as VARCHAR)
        and cast(tk.kokrs as VARCHAR) = cast(a.kokrs as VARCHAR)
    inner join main_sap.stg_sap__t000 as s
        on cast(s.mandt as VARCHAR) = cast(a.rclnt as VARCHAR)
    where
        (
            (cast(a.co_buzei as VARCHAR) != '000' and cast(a.accasty as VARCHAR) != '')
            or (cast(a.mig_source as VARCHAR) = 'C' and cast(a.bstat as VARCHAR) = 'C')
        )
        and (
            cast(s.logsys as VARCHAR) = cast(a.logsyso as VARCHAR)
            or cast(a.logsyso as VARCHAR) = ''
            or (
                a.accasty in ('KS', 'KL')
                and (cast(s.logsys as VARCHAR) = cast(tk.logsystem as VARCHAR) or cast(tk.logsystem as VARCHAR) = '')
            )
        )
        and cast(a.objnr as VARCHAR) != ''

)

select * from acdoca_base
),
__dbt__cte__int_cosp__acdoca_amounts as (
-- Second step of ACDOCA transformation for COSP compatibility
-- Calculates final amounts by subtracting add/subtract values

with acdoca_amounts as (

    select
        mandt,
        lednr,
        objnr,
        gjahr,
        wrttp,
        versn,
        kstar,
        hrkft,
        vrgng,
        vbund,
        pargb,
        beknz,
        twaer,
        rldnr,
        perio,
        meinh,
        -- Calculate final amounts by subtracting
        (wtgbtr_add - wtgbtr_subtract) as wtgbtr,
        (wogbtr_add - wogbtr_subtract) as wogbtr,
        (wkgbtr_add - wkgbtr_subtract) as wkgbtr,
        (wkfbtr_add - wkfbtr_subtract) as wkfbtr,
        (pagbtr_add - pagbtr_subtract) as pagbtr,
        megbtr,
        mefbtr,
        muvflg,
        beltp,
        bukrs,
        fkber,
        segment,
        geber,
        grant_nbr,
        budget_pd,
        timestamp_at

    from __dbt__cte__int_cosp__acdoca_base

)

select * from acdoca_amounts
),
__dbt__cte__int_cosp__acdoca_timestamp as (
-- Third step of ACDOCA transformation for COSP compatibility
-- Handles complex timestamp transformations from the original SAP logic

with acdoca_timestamp as (

    select
        mandt,
        lednr,
        objnr,
        gjahr,
        wrttp,
        versn,
        kstar,
        hrkft,
        vrgng,
        vbund,
        pargb,
        beknz,
        twaer,
        perio,
        meinh,
        wtgbtr,
        wogbtr,
        wkgbtr,
        wkfbtr,
        pagbtr,
        megbtr,
        mefbtr,
        muvflg,
        beltp,
        bukrs,
        fkber,
        segment,
        geber,
        grant_nbr,
        budget_pd,
        -- Simplified timestamp handling - using original timestamp
        -- The original SQL had very complex timestamp calculations that we'll simplify
        case
            when timestamp_at > 0 then timestamp_at * 10000
            else 0
        end as timestmp

    from __dbt__cte__int_cosp__acdoca_amounts

)

select * from acdoca_timestamp
),
__dbt__cte__int_cosp__coep_derived as (
-- COEP-derived records for COSP compatibility view
-- Handles the V_COSP_R_3S logic from the original SQL

with coep_base as (

    select
        c.mandt,
        c.lednr,
        c.objnr,
        c.gjahr,
        c.wrttp,
        c.versn,
        c.kstar,
        c.hrkft,
        c.vrgng,
        c.vbund,
        c.pargb,
        c.beknz,
        c.twaer,
        c.perio,
        c.meinh,
        c.wtgbtr,
        c.wogbtr,
        c.wkgbtr,
        c.wkfbtr,
        c.pagbtr,
        c.megbtr,
        c.mefbtr,
        c.beltp,
        c.timestmp,
        c.bukrs,
        c.fkber,
        c.segment,
        c.geber,
        c.grant_nbr,
        c.budget_pd,
        c.mvflg,
        c.meinb,
        -- Calculate MUVFLG based on complex logic from original
        case
            when (cast(c.mvflg as VARCHAR) = '' and c.megbtr = 0 and c.mefbtr = 0) then
                case
                    when (c.meinb = c.meinh or coalesce(t_meinh.dimid, '') = coalesce(t_meinb.dimid, '')) then cast('0' as VARCHAR)
                    else cast('1' as VARCHAR)
                end
            else
                case
                    when cast(c.mvflg as VARCHAR) = 'Y' then cast('1' as VARCHAR)
                    when (cast(c.mvflg as VARCHAR) = '' and c.megbtr = 0 and c.mefbtr = 0) then cast('1' as VARCHAR)
                    else cast('0' as VARCHAR)
                end
        end as muvflg_calc

    from main_sap.stg_sap__coep as c
    inner join main_sap.stg_sap__tj01 as j
        on cast(j.vrgng as VARCHAR) = cast(c.vrgng as VARCHAR)
        and cast(j.wtkat as VARCHAR) = 'A'
        and cast(j.xcosp as VARCHAR) = 'X'
    left join main_sap.stg_sap__t006 as t_meinb
        on cast(t_meinb.mandt as VARCHAR) = cast(c.mandt as VARCHAR)
        and cast(t_meinb.msehi as VARCHAR) = cast(c.meinb as VARCHAR)
    left join main_sap.stg_sap__t006 as t_meinh
        on cast(t_meinh.mandt as VARCHAR) = cast(c.mandt as VARCHAR)
        and cast(t_meinh.msehi as VARCHAR) = cast(c.meinh as VARCHAR)
    inner join main_sap.stg_sap__tka01 as t
        on cast(t.mandt as VARCHAR) = cast(c.mandt as VARCHAR)
        and cast(t.kokrs as VARCHAR) = cast(c.kokrs as VARCHAR)
    inner join main_sap.stg_sap__t000 as s
        on cast(s.mandt as VARCHAR) = cast(c.mandt as VARCHAR)
        and (
            cast(s.logsys as VARCHAR) = cast(c.logsyso as VARCHAR)
            or cast(c.logsyso as VARCHAR) = ''
            or (
                c.accasty in ('KS', 'KL')
                and (cast(s.logsys as VARCHAR) = cast(t.logsystem as VARCHAR) or cast(t.logsystem as VARCHAR) = '')
            )
        )
    where cast(c.wrttp as VARCHAR) = '11'

),

coep_final as (

    select
        mandt,
        lednr,
        objnr,
        gjahr,
        cast('11' as VARCHAR) as wrttp,
        versn,
        kstar,
        hrkft,
        vrgng,
        vbund,
        pargb,
        beknz,
        twaer,
        perio,
        meinh,
        wtgbtr,
        wogbtr,
        wkgbtr,
        wkfbtr,
        pagbtr,
        megbtr,
        mefbtr,
        case
            when cast(muvflg_calc as VARCHAR) = '1' then 1
            else 0
        end as muvflg,
        beltp,
        timestmp,
        bukrs,
        fkber,
        segment,
        geber,
        grant_nbr,
        budget_pd

    from coep_base

)

select * from coep_final
),
__dbt__cte__int_cosp__acdoca_derived as (
-- Union of ACDOCA-derived and COEP-derived records for COSP compatibility
-- Combines data from both transformation paths

with acdoca_records as (

    select
        cast(mandt as VARCHAR) as mandt,
        cast(lednr as VARCHAR) as lednr,
        cast(objnr as VARCHAR) as objnr,
        cast(gjahr as VARCHAR) as gjahr,
        cast(wrttp as VARCHAR) as wrttp,
        cast(versn as VARCHAR) as versn,
        cast(kstar as VARCHAR) as kstar,
        cast(hrkft as VARCHAR) as hrkft,
        cast(vrgng as VARCHAR) as vrgng,
        cast(vbund as VARCHAR) as vbund,
        cast(pargb as VARCHAR) as pargb,
        cast(beknz as VARCHAR) as beknz,
        cast(twaer as VARCHAR) as twaer,
        cast(perio as VARCHAR) as perio,
        cast(meinh as VARCHAR) as meinh,
        cast(wtgbtr as NUMERIC) as wtgbtr,
        cast(wogbtr as NUMERIC) as wogbtr,
        cast(wkgbtr as NUMERIC) as wkgbtr,
        cast(wkfbtr as NUMERIC) as wkfbtr,
        cast(pagbtr as NUMERIC) as pagbtr,
        cast(megbtr as NUMERIC) as megbtr,
        cast(mefbtr as NUMERIC) as mefbtr,
        cast(muvflg as INTEGER) as muvflg,
        cast(beltp as VARCHAR) as beltp,
        cast(timestmp as VARCHAR) as timestmp,
        cast(bukrs as VARCHAR) as bukrs,
        cast(fkber as VARCHAR) as fkber,
        cast(segment as VARCHAR) as segment,
        cast(geber as VARCHAR) as geber,
        cast(grant_nbr as VARCHAR) as grant_nbr,
        cast(budget_pd as VARCHAR) as budget_pd

    from __dbt__cte__int_cosp__acdoca_timestamp

),

coep_records as (

    select
        cast(mandt as VARCHAR) as mandt,
        cast(lednr as VARCHAR) as lednr,
        cast(objnr as VARCHAR) as objnr,
        cast(gjahr as VARCHAR) as gjahr,
        cast(wrttp as VARCHAR) as wrttp,
        cast(versn as VARCHAR) as versn,
        cast(kstar as VARCHAR) as kstar,
        cast(hrkft as VARCHAR) as hrkft,
        cast(vrgng as VARCHAR) as vrgng,
        cast(vbund as VARCHAR) as vbund,
        cast(pargb as VARCHAR) as pargb,
        cast(beknz as VARCHAR) as beknz,
        cast(twaer as VARCHAR) as twaer,
        cast(perio as VARCHAR) as perio,
        cast(meinh as VARCHAR) as meinh,
        cast(wtgbtr as NUMERIC) as wtgbtr,
        cast(wogbtr as NUMERIC) as wogbtr,
        cast(wkgbtr as NUMERIC) as wkgbtr,
        cast(wkfbtr as NUMERIC) as wkfbtr,
        cast(pagbtr as NUMERIC) as pagbtr,
        cast(megbtr as NUMERIC) as megbtr,
        cast(mefbtr as NUMERIC) as mefbtr,
        cast(muvflg as INTEGER) as muvflg,
        cast(beltp as VARCHAR) as beltp,
        cast(timestmp as VARCHAR) as timestmp,
        cast(bukrs as VARCHAR) as bukrs,
        cast(fkber as VARCHAR) as fkber,
        cast(segment as VARCHAR) as segment,
        cast(geber as VARCHAR) as geber,
        cast(grant_nbr as VARCHAR) as grant_nbr,
        cast(budget_pd as VARCHAR) as budget_pd

    from __dbt__cte__int_cosp__coep_derived

)

select * from acdoca_records
union all
select * from coep_records
),
cosp_from_archive as (

    select
        cast(mandt as VARCHAR) as mandt,
        cast('00' as VARCHAR) as lednr,
        cast(objnr as VARCHAR) as objnr,
        cast(gjahr as VARCHAR) as gjahr,
        cast(wrttp as VARCHAR) as wrttp,
        cast(versn as VARCHAR) as versn,
        cast(kstar as VARCHAR) as kstar,
        cast(hrkft as VARCHAR) as hrkft,
        cast(vrgng as VARCHAR) as vrgng,
        cast(vbund as VARCHAR) as vbund,
        cast(pargb as VARCHAR) as pargb,
        cast(beknz as VARCHAR) as beknz,
        cast(twaer as VARCHAR) as twaer,
        cast('016' as VARCHAR) as perbl,
        cast(meinh as VARCHAR) as meinh,
        cast(wtg001 as NUMERIC) as wtg001,
        cast(wtg002 as NUMERIC) as wtg002,
        cast(wtg003 as NUMERIC) as wtg003,
        cast(wtg004 as NUMERIC) as wtg004,
        cast(wtg005 as NUMERIC) as wtg005,
        cast(wtg006 as NUMERIC) as wtg006,
        cast(wtg007 as NUMERIC) as wtg007,
        cast(wtg008 as NUMERIC) as wtg008,
        cast(wtg009 as NUMERIC) as wtg009,
        cast(wtg010 as NUMERIC) as wtg010,
        cast(wtg011 as NUMERIC) as wtg011,
        cast(wtg012 as NUMERIC) as wtg012,
        cast(wtg013 as NUMERIC) as wtg013,
        cast(wtg014 as NUMERIC) as wtg014,
        cast(wtg015 as NUMERIC) as wtg015,
        cast(wtg016 as NUMERIC) as wtg016,
        cast(wog001 as NUMERIC) as wog001,
        cast(wog002 as NUMERIC) as wog002,
        cast(wog003 as NUMERIC) as wog003,
        cast(wog004 as NUMERIC) as wog004,
        cast(wog005 as NUMERIC) as wog005,
        cast(wog006 as NUMERIC) as wog006,
        cast(wog007 as NUMERIC) as wog007,
        cast(wog008 as NUMERIC) as wog008,
        cast(wog009 as NUMERIC) as wog009,
        cast(wog010 as NUMERIC) as wog010,
        cast(wog011 as NUMERIC) as wog011,
        cast(wog012 as NUMERIC) as wog012,
        cast(wog013 as NUMERIC) as wog013,
        cast(wog014 as NUMERIC) as wog014,
        cast(wog015 as NUMERIC) as wog015,
        cast(wog016 as NUMERIC) as wog016,
        cast(wkg001 as NUMERIC) as wkg001,
        cast(wkg002 as NUMERIC) as wkg002,
        cast(wkg003 as NUMERIC) as wkg003,
        cast(wkg004 as NUMERIC) as wkg004,
        cast(wkg005 as NUMERIC) as wkg005,
        cast(wkg006 as NUMERIC) as wkg006,
        cast(wkg007 as NUMERIC) as wkg007,
        cast(wkg008 as NUMERIC) as wkg008,
        cast(wkg009 as NUMERIC) as wkg009,
        cast(wkg010 as NUMERIC) as wkg010,
        cast(wkg011 as NUMERIC) as wkg011,
        cast(wkg012 as NUMERIC) as wkg012,
        cast(wkg013 as NUMERIC) as wkg013,
        cast(wkg014 as NUMERIC) as wkg014,
        cast(wkg015 as NUMERIC) as wkg015,
        cast(wkg016 as NUMERIC) as wkg016,
        cast(wkf001 as NUMERIC) as wkf001,
        cast(wkf002 as NUMERIC) as wkf002,
        cast(wkf003 as NUMERIC) as wkf003,
        cast(wkf004 as NUMERIC) as wkf004,
        cast(wkf005 as NUMERIC) as wkf005,
        cast(wkf006 as NUMERIC) as wkf006,
        cast(wkf007 as NUMERIC) as wkf007,
        cast(wkf008 as NUMERIC) as wkf008,
        cast(wkf009 as NUMERIC) as wkf009,
        cast(wkf010 as NUMERIC) as wkf010,
        cast(wkf011 as NUMERIC) as wkf011,
        cast(wkf012 as NUMERIC) as wkf012,
        cast(wkf013 as NUMERIC) as wkf013,
        cast(wkf014 as NUMERIC) as wkf014,
        cast(wkf015 as NUMERIC) as wkf015,
        cast(wkf016 as NUMERIC) as wkf016,
        cast(pag001 as NUMERIC) as pag001,
        cast(pag002 as NUMERIC) as pag002,
        cast(pag003 as NUMERIC) as pag003,
        cast(pag004 as NUMERIC) as pag004,
        cast(pag005 as NUMERIC) as pag005,
        cast(pag006 as NUMERIC) as pag006,
        cast(pag007 as NUMERIC) as pag007,
        cast(pag008 as NUMERIC) as pag008,
        cast(pag009 as NUMERIC) as pag009,
        cast(pag010 as NUMERIC) as pag010,
        cast(pag011 as NUMERIC) as pag011,
        cast(pag012 as NUMERIC) as pag012,
        cast(pag013 as NUMERIC) as pag013,
        cast(pag014 as NUMERIC) as pag014,
        cast(pag015 as NUMERIC) as pag015,
        cast(pag016 as NUMERIC) as pag016,
        cast(meg001 as NUMERIC) as meg001,
        cast(meg002 as NUMERIC) as meg002,
        cast(meg003 as NUMERIC) as meg003,
        cast(meg004 as NUMERIC) as meg004,
        cast(meg005 as NUMERIC) as meg005,
        cast(meg006 as NUMERIC) as meg006,
        cast(meg007 as NUMERIC) as meg007,
        cast(meg008 as NUMERIC) as meg008,
        cast(meg009 as NUMERIC) as meg009,
        cast(meg010 as NUMERIC) as meg010,
        cast(meg011 as NUMERIC) as meg011,
        cast(meg012 as NUMERIC) as meg012,
        cast(meg013 as NUMERIC) as meg013,
        cast(meg014 as NUMERIC) as meg014,
        cast(meg015 as NUMERIC) as meg015,
        cast(meg016 as NUMERIC) as meg016,
        cast(mef001 as NUMERIC) as mef001,
        cast(mef002 as NUMERIC) as mef002,
        cast(mef003 as NUMERIC) as mef003,
        cast(mef004 as NUMERIC) as mef004,
        cast(mef005 as NUMERIC) as mef005,
        cast(mef006 as NUMERIC) as mef006,
        cast(mef007 as NUMERIC) as mef007,
        cast(mef008 as NUMERIC) as mef008,
        cast(mef009 as NUMERIC) as mef009,
        cast(mef010 as NUMERIC) as mef010,
        cast(mef011 as NUMERIC) as mef011,
        cast(mef012 as NUMERIC) as mef012,
        cast(mef013 as NUMERIC) as mef013,
        cast(mef014 as NUMERIC) as mef014,
        cast(mef015 as NUMERIC) as mef015,
        cast(mef016 as NUMERIC) as mef016,
        cast(muv001 as VARCHAR) as muv001,
        cast(muv002 as VARCHAR) as muv002,
        cast(muv003 as VARCHAR) as muv003,
        cast(muv004 as VARCHAR) as muv004,
        cast(muv005 as VARCHAR) as muv005,
        cast(muv006 as VARCHAR) as muv006,
        cast(muv007 as VARCHAR) as muv007,
        cast(muv008 as VARCHAR) as muv008,
        cast(muv009 as VARCHAR) as muv009,
        cast(muv010 as VARCHAR) as muv010,
        cast(muv011 as VARCHAR) as muv011,
        cast(muv012 as VARCHAR) as muv012,
        cast(muv013 as VARCHAR) as muv013,
        cast(muv014 as VARCHAR) as muv014,
        cast(muv015 as VARCHAR) as muv015,
        cast(muv016 as VARCHAR) as muv016,
        cast(beltp as VARCHAR) as beltp,
        cast(timestmp as NUMERIC) as timestmp,
        cast(bukrs as VARCHAR) as bukrs,
        cast(fkber as VARCHAR) as fkber,
        cast(segment as VARCHAR) as segment,
        cast(geber as VARCHAR) as geber,
        cast(grant_nbr as VARCHAR) as grant_nbr,
        cast(budget_pd as VARCHAR) as budget_pd

    from main_sap.stg_sap__cosp_bak
    where not (cast(wrttp as VARCHAR) = '04' or cast(wrttp as VARCHAR) = '11')

),

cosp_from_acdoca_aggregated as (

    select
        cast(mandt as VARCHAR) as mandt,
        cast('00' as VARCHAR) as lednr,
        cast(objnr as VARCHAR) as objnr,
        cast(gjahr as VARCHAR) as gjahr,
        cast(wrttp as VARCHAR) as wrttp,
        cast(versn as VARCHAR) as versn,
        cast(kstar as VARCHAR) as kstar,
        cast(hrkft as VARCHAR) as hrkft,
        cast(vrgng as VARCHAR) as vrgng,
        cast(vbund as VARCHAR) as vbund,
        cast(pargb as VARCHAR) as pargb,
        cast(beknz as VARCHAR) as beknz,
        cast(twaer as VARCHAR) as twaer,
        cast('016' as VARCHAR) as perbl,
        cast(meinh as VARCHAR) as meinh,
        cast(beltp as VARCHAR) as beltp,
        cast(bukrs as VARCHAR) as bukrs,
        cast(fkber as VARCHAR) as fkber,
        cast(segment as VARCHAR) as segment,
        cast(geber as VARCHAR) as geber,
        cast(grant_nbr as VARCHAR) as grant_nbr,
        cast(budget_pd as VARCHAR) as budget_pd,
        -- Period-based transaction currency amounts
        sum(case when cast(perio as VARCHAR) = '001' then wtgbtr else 0 end) as wtg001,
        sum(case when cast(perio as VARCHAR) = '002' then wtgbtr else 0 end) as wtg002,
        sum(case when cast(perio as VARCHAR) = '003' then wtgbtr else 0 end) as wtg003,
        sum(case when cast(perio as VARCHAR) = '004' then wtgbtr else 0 end) as wtg004,
        sum(case when cast(perio as VARCHAR) = '005' then wtgbtr else 0 end) as wtg005,
        sum(case when cast(perio as VARCHAR) = '006' then wtgbtr else 0 end) as wtg006,
        sum(case when cast(perio as VARCHAR) = '007' then wtgbtr else 0 end) as wtg007,
        sum(case when cast(perio as VARCHAR) = '008' then wtgbtr else 0 end) as wtg008,
        sum(case when cast(perio as VARCHAR) = '009' then wtgbtr else 0 end) as wtg009,
        sum(case when cast(perio as VARCHAR) = '010' then wtgbtr else 0 end) as wtg010,
        sum(case when cast(perio as VARCHAR) = '011' then wtgbtr else 0 end) as wtg011,
        sum(case when cast(perio as VARCHAR) = '012' then wtgbtr else 0 end) as wtg012,
        sum(case when cast(perio as VARCHAR) = '013' then wtgbtr else 0 end) as wtg013,
        sum(case when cast(perio as VARCHAR) = '014' then wtgbtr else 0 end) as wtg014,
        sum(case when cast(perio as VARCHAR) = '015' then wtgbtr else 0 end) as wtg015,
        sum(case when cast(perio as VARCHAR) = '016' then wtgbtr else 0 end) as wtg016,
        -- Period-based object currency amounts
        sum(case when cast(perio as VARCHAR) = '001' then wogbtr else 0 end) as wog001,
        sum(case when cast(perio as VARCHAR) = '002' then wogbtr else 0 end) as wog002,
        sum(case when cast(perio as VARCHAR) = '003' then wogbtr else 0 end) as wog003,
        sum(case when cast(perio as VARCHAR) = '004' then wogbtr else 0 end) as wog004,
        sum(case when cast(perio as VARCHAR) = '005' then wogbtr else 0 end) as wog005,
        sum(case when cast(perio as VARCHAR) = '006' then wogbtr else 0 end) as wog006,
        sum(case when cast(perio as VARCHAR) = '007' then wogbtr else 0 end) as wog007,
        sum(case when cast(perio as VARCHAR) = '008' then wogbtr else 0 end) as wog008,
        sum(case when cast(perio as VARCHAR) = '009' then wogbtr else 0 end) as wog009,
        sum(case when cast(perio as VARCHAR) = '010' then wogbtr else 0 end) as wog010,
        sum(case when cast(perio as VARCHAR) = '011' then wogbtr else 0 end) as wog011,
        sum(case when cast(perio as VARCHAR) = '012' then wogbtr else 0 end) as wog012,
        sum(case when cast(perio as VARCHAR) = '013' then wogbtr else 0 end) as wog013,
        sum(case when cast(perio as VARCHAR) = '014' then wogbtr else 0 end) as wog014,
        sum(case when cast(perio as VARCHAR) = '015' then wogbtr else 0 end) as wog015,
        sum(case when cast(perio as VARCHAR) = '016' then wogbtr else 0 end) as wog016,
        -- Period-based controlling currency amounts
        sum(case when cast(perio as VARCHAR) = '001' then wkgbtr else 0 end) as wkg001,
        sum(case when cast(perio as VARCHAR) = '002' then wkgbtr else 0 end) as wkg002,
        sum(case when cast(perio as VARCHAR) = '003' then wkgbtr else 0 end) as wkg003,
        sum(case when cast(perio as VARCHAR) = '004' then wkgbtr else 0 end) as wkg004,
        sum(case when cast(perio as VARCHAR) = '005' then wkgbtr else 0 end) as wkg005,
        sum(case when cast(perio as VARCHAR) = '006' then wkgbtr else 0 end) as wkg006,
        sum(case when cast(perio as VARCHAR) = '007' then wkgbtr else 0 end) as wkg007,
        sum(case when cast(perio as VARCHAR) = '008' then wkgbtr else 0 end) as wkg008,
        sum(case when cast(perio as VARCHAR) = '009' then wkgbtr else 0 end) as wkg009,
        sum(case when cast(perio as VARCHAR) = '010' then wkgbtr else 0 end) as wkg010,
        sum(case when cast(perio as VARCHAR) = '011' then wkgbtr else 0 end) as wkg011,
        sum(case when cast(perio as VARCHAR) = '012' then wkgbtr else 0 end) as wkg012,
        sum(case when cast(perio as VARCHAR) = '013' then wkgbtr else 0 end) as wkg013,
        sum(case when cast(perio as VARCHAR) = '014' then wkgbtr else 0 end) as wkg014,
        sum(case when cast(perio as VARCHAR) = '015' then wkgbtr else 0 end) as wkg015,
        sum(case when cast(perio as VARCHAR) = '016' then wkgbtr else 0 end) as wkg016,
        -- Period-based fixed currency amounts
        sum(case when cast(perio as VARCHAR) = '001' then wkfbtr else 0 end) as wkf001,
        sum(case when cast(perio as VARCHAR) = '002' then wkfbtr else 0 end) as wkf002,
        sum(case when cast(perio as VARCHAR) = '003' then wkfbtr else 0 end) as wkf003,
        sum(case when cast(perio as VARCHAR) = '004' then wkfbtr else 0 end) as wkf004,
        sum(case when cast(perio as VARCHAR) = '005' then wkfbtr else 0 end) as wkf005,
        sum(case when cast(perio as VARCHAR) = '006' then wkfbtr else 0 end) as wkf006,
        sum(case when cast(perio as VARCHAR) = '007' then wkfbtr else 0 end) as wkf007,
        sum(case when cast(perio as VARCHAR) = '008' then wkfbtr else 0 end) as wkf008,
        sum(case when cast(perio as VARCHAR) = '009' then wkfbtr else 0 end) as wkf009,
        sum(case when cast(perio as VARCHAR) = '010' then wkfbtr else 0 end) as wkf010,
        sum(case when cast(perio as VARCHAR) = '011' then wkfbtr else 0 end) as wkf011,
        sum(case when cast(perio as VARCHAR) = '012' then wkfbtr else 0 end) as wkf012,
        sum(case when cast(perio as VARCHAR) = '013' then wkfbtr else 0 end) as wkf013,
        sum(case when cast(perio as VARCHAR) = '014' then wkfbtr else 0 end) as wkf014,
        sum(case when cast(perio as VARCHAR) = '015' then wkfbtr else 0 end) as wkf015,
        sum(case when cast(perio as VARCHAR) = '016' then wkfbtr else 0 end) as wkf016,
        -- Period-based plan amounts
        sum(case when cast(perio as VARCHAR) = '001' then pagbtr else 0 end) as pag001,
        sum(case when cast(perio as VARCHAR) = '002' then pagbtr else 0 end) as pag002,
        sum(case when cast(perio as VARCHAR) = '003' then pagbtr else 0 end) as pag003,
        sum(case when cast(perio as VARCHAR) = '004' then pagbtr else 0 end) as pag004,
        sum(case when cast(perio as VARCHAR) = '005' then pagbtr else 0 end) as pag005,
        sum(case when cast(perio as VARCHAR) = '006' then pagbtr else 0 end) as pag006,
        sum(case when cast(perio as VARCHAR) = '007' then pagbtr else 0 end) as pag007,
        sum(case when cast(perio as VARCHAR) = '008' then pagbtr else 0 end) as pag008,
        sum(case when cast(perio as VARCHAR) = '009' then pagbtr else 0 end) as pag009,
        sum(case when cast(perio as VARCHAR) = '010' then pagbtr else 0 end) as pag010,
        sum(case when cast(perio as VARCHAR) = '011' then pagbtr else 0 end) as pag011,
        sum(case when cast(perio as VARCHAR) = '012' then pagbtr else 0 end) as pag012,
        sum(case when cast(perio as VARCHAR) = '013' then pagbtr else 0 end) as pag013,
        sum(case when cast(perio as VARCHAR) = '014' then pagbtr else 0 end) as pag014,
        sum(case when cast(perio as VARCHAR) = '015' then pagbtr else 0 end) as pag015,
        sum(case when cast(perio as VARCHAR) = '016' then pagbtr else 0 end) as pag016,
        -- Period-based quantity amounts
        sum(case when cast(perio as VARCHAR) = '001' then megbtr else 0 end) as meg001,
        sum(case when cast(perio as VARCHAR) = '002' then megbtr else 0 end) as meg002,
        sum(case when cast(perio as VARCHAR) = '003' then megbtr else 0 end) as meg003,
        sum(case when cast(perio as VARCHAR) = '004' then megbtr else 0 end) as meg004,
        sum(case when cast(perio as VARCHAR) = '005' then megbtr else 0 end) as meg005,
        sum(case when cast(perio as VARCHAR) = '006' then megbtr else 0 end) as meg006,
        sum(case when cast(perio as VARCHAR) = '007' then megbtr else 0 end) as meg007,
        sum(case when cast(perio as VARCHAR) = '008' then megbtr else 0 end) as meg008,
        sum(case when cast(perio as VARCHAR) = '009' then megbtr else 0 end) as meg009,
        sum(case when cast(perio as VARCHAR) = '010' then megbtr else 0 end) as meg010,
        sum(case when cast(perio as VARCHAR) = '011' then megbtr else 0 end) as meg011,
        sum(case when cast(perio as VARCHAR) = '012' then megbtr else 0 end) as meg012,
        sum(case when cast(perio as VARCHAR) = '013' then megbtr else 0 end) as meg013,
        sum(case when cast(perio as VARCHAR) = '014' then megbtr else 0 end) as meg014,
        sum(case when cast(perio as VARCHAR) = '015' then megbtr else 0 end) as meg015,
        sum(case when cast(perio as VARCHAR) = '016' then megbtr else 0 end) as meg016,
        -- Period-based fixed quantity amounts
        sum(case when cast(perio as VARCHAR) = '001' then mefbtr else 0 end) as mef001,
        sum(case when cast(perio as VARCHAR) = '002' then mefbtr else 0 end) as mef002,
        sum(case when cast(perio as VARCHAR) = '003' then mefbtr else 0 end) as mef003,
        sum(case when cast(perio as VARCHAR) = '004' then mefbtr else 0 end) as mef004,
        sum(case when cast(perio as VARCHAR) = '005' then mefbtr else 0 end) as mef005,
        sum(case when cast(perio as VARCHAR) = '006' then mefbtr else 0 end) as mef006,
        sum(case when cast(perio as VARCHAR) = '007' then mefbtr else 0 end) as mef007,
        sum(case when cast(perio as VARCHAR) = '008' then mefbtr else 0 end) as mef008,
        sum(case when cast(perio as VARCHAR) = '009' then mefbtr else 0 end) as mef009,
        sum(case when cast(perio as VARCHAR) = '010' then mefbtr else 0 end) as mef010,
        sum(case when cast(perio as VARCHAR) = '011' then mefbtr else 0 end) as mef011,
        sum(case when cast(perio as VARCHAR) = '012' then mefbtr else 0 end) as mef012,
        sum(case when cast(perio as VARCHAR) = '013' then mefbtr else 0 end) as mef013,
        sum(case when cast(perio as VARCHAR) = '014' then mefbtr else 0 end) as mef014,
        sum(case when cast(perio as VARCHAR) = '015' then mefbtr else 0 end) as mef015,
        sum(case when cast(perio as VARCHAR) = '016' then mefbtr else 0 end) as mef016,
        -- Period-based manual update flags
        case when max(case when cast(perio as VARCHAR) = '001' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv001,
        case when max(case when cast(perio as VARCHAR) = '002' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv002,
        case when max(case when cast(perio as VARCHAR) = '003' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv003,
        case when max(case when cast(perio as VARCHAR) = '004' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv004,
        case when max(case when cast(perio as VARCHAR) = '005' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv005,
        case when max(case when cast(perio as VARCHAR) = '006' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv006,
        case when max(case when cast(perio as VARCHAR) = '007' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv007,
        case when max(case when cast(perio as VARCHAR) = '008' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv008,
        case when max(case when cast(perio as VARCHAR) = '009' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv009,
        case when max(case when cast(perio as VARCHAR) = '010' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv010,
        case when max(case when cast(perio as VARCHAR) = '011' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv011,
        case when max(case when cast(perio as VARCHAR) = '012' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv012,
        case when max(case when cast(perio as VARCHAR) = '013' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv013,
        case when max(case when cast(perio as VARCHAR) = '014' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv014,
        case when max(case when cast(perio as VARCHAR) = '015' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv015,
        case when max(case when cast(perio as VARCHAR) = '016' then muvflg else 0 end) = 1 then cast('X' as VARCHAR) else cast('' as VARCHAR) end as muv016,
        cast(max(timestmp) as NUMERIC) as timestmp

    from __dbt__cte__int_cosp__acdoca_derived
    where cast(wrttp as VARCHAR) in ('04', '11')
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22

),

cosp_from_acdoca as (

    select
        mandt,
        lednr,
        objnr,
        gjahr,
        wrttp,
        versn,
        kstar,
        hrkft,
        vrgng,
        vbund,
        pargb,
        beknz,
        twaer,
        perbl,
        meinh,
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
        muv001,
        muv002,
        muv003,
        muv004,
        muv005,
        muv006,
        muv007,
        muv008,
        muv009,
        muv010,
        muv011,
        muv012,
        muv013,
        muv014,
        muv015,
        muv016,
        beltp,
        timestmp,
        bukrs,
        fkber,
        segment,
        geber,
        grant_nbr,
        budget_pd

    from cosp_from_acdoca_aggregated

)

select * from cosp_from_archive
union all
select * from cosp_from_acdoca
