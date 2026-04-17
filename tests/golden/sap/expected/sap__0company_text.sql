with t880 as ( 

	select * 
	from "sap"."main_sap"."stg_sap__t880"
),

final as (

    select 
        mandt,
        rcomp,
        name1 as txtmd
    from t880
)

select * 
from final
