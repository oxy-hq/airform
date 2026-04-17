with ska1 as ( 

	select * 
	from "sap"."main_sap"."stg_sap__ska1"
),

final as (

	select
		mandt, 
		ktopl,
		saknr,
		bilkt,
		gvtyp,
		vbund,
		xbilk,
		sakan,
		erdat,
		ernam,
		ktoks,
		xloev,
		xspea,
		xspeb,
		xspep,
		func_area,
		mustr	
	from ska1

	
)

select * 
from final
