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
