with t001 as ( 

	select * 
	from "sap"."main_sap"."stg_sap__t001"
),

final as (

    select
        mandt,
        bukrs,
        butxt as txtmd,
        spras as langu
    from t001
)

select * 
from final
