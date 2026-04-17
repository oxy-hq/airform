with users as (
  select *
  from "zendesk"."main_zendesk_source"."stg_zendesk__user"

--If you use user tags this will be included, if not it will be ignored.

), user_tags as (

  select *
  from "zendesk"."main_zendesk_source"."stg_zendesk__user_tag"
  
), user_tag_aggregate as (
  select
    user_tags.user_id,
    source_relation,
    
    string_agg(user_tags.tags, ', ')

 as user_tags
  from user_tags
  group by 1, 2



), final as (
  select 
    users.*,
    users.role in ('agent','admin') as is_internal_role

    --If you use user tags this will be included, if not it will be ignored.
    
    , user_tag_aggregate.user_tags
    
  from users

  --If you use user tags this will be included, if not it will be ignored.
  
  left join user_tag_aggregate
    on users.user_id = user_tag_aggregate.user_id 
    and users.source_relation = user_tag_aggregate.source_relation
  
)

select *
from final
