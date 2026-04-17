select
    opportunity_prospect_id as unique_field,
    count(*) as n_records

from "pardot"."main_stg_pardot"."stg_pardot__opportunity_prospect"
where opportunity_prospect_id is not null
group by opportunity_prospect_id
having count(*) > 1
