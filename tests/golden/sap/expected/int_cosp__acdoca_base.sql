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
