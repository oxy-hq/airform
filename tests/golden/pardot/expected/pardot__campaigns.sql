with opportunities_tmp as (
    select * 
    from "pardot"."main_pardot"."int__opportunity_tmp" 
    
), opportunities as ( 
    select 
        source_relation, campaign_id,
        count(*) as count_opportunities
    
         
    from opportunities_tmp 
    group by 1, 2 
    
), campaigns as ( 
    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__campaign" 

), prospects as ( 
    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__prospect" 
    
), prospects_xf as ( 
    select 
        source_relation, 
        campaign_id, 
        count(*) as count_prospects 
    from prospects 
    group by 1, 2 
    
), joined as ( 
    select 
        campaigns.*, 

         
        prospects_xf.count_prospects 
    from campaigns 
    left join opportunities 
        on campaigns.campaign_id = opportunities.campaign_id 
        and campaigns.source_relation = opportunities.source_relation 
    left join prospects_xf 
        on campaigns.campaign_id = prospects_xf.campaign_id 
        and campaigns.source_relation = prospects_xf.source_relation 
    
) 

select * 
from joined
