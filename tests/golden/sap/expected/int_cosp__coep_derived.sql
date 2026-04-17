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
