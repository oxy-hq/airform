with lfa1 as ( 

	select * 
	from "sap"."main_sap"."stg_sap__lfa1"
),

final as (

    select
        mandt,
        lifnr,
        name1 as txtmd
    from lfa1
)

select * 
from final
