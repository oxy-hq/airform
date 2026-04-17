with t001 as ( 

	select * 
	from "sap"."main_sap"."stg_sap__t001"
),

final as (

    select
        mandt,
        bukrs,
        land1,
        waers,
        ktopl,
        kkber,
        periv,
        rcomp
    from t001

    
)

select * 
from final
