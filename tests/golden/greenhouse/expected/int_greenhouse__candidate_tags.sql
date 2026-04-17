with greeenhouse_tag as (

    select *
    from main_stg_greenhouse.stg_greenhouse__tag
),

candidate_tag as (

    select *
    from main_stg_greenhouse.stg_greenhouse__candidate_tag
),

agg_tags as (

    select
        candidate_tag.source_relation,
        candidate_tag.candidate_id,
        STRING_AGG(greeenhouse_tag.tag_name, ', ') as tags 

    from candidate_tag 
    join greeenhouse_tag
        on candidate_tag.tag_id = greeenhouse_tag.tag_id
        and candidate_tag.source_relation = greeenhouse_tag.source_relation

    group by 1, 2
)

select * 
from agg_tags
