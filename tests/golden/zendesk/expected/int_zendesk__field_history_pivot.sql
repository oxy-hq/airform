-- depends_on: "zendesk"."main_zendesk_source"."stg_zendesk__ticket_field_history"



with  __dbt__cte__int_zendesk__updater_information as (
with users as (
    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__user_aggregates"

--If using organizations, this will be included, if not it will be ignored.

), organizations as (
    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__organization_aggregates"


), final as (
    select
        users.source_relation,
        users.user_id as updater_user_id
        ,users.name as updater_name
        ,users.role as updater_role
        ,users.email as updater_email
        ,users.external_id as updater_external_id
        ,users.locale as updater_locale
        ,users.is_active as updater_is_active

        --If you use user tags this will be included, if not it will be ignored.
        
        ,users.user_tags as updater_user_tags
        

        ,users.last_login_at as updater_last_login_at
        ,users.time_zone as updater_time_zone
        
        ,organizations.organization_id as updater_organization_id
        

        --If you use using_domain_names tags this will be included, if not it will be ignored.
        
        ,organizations.domain_names as updater_organization_domain_names
        

        --If you use organization tags, this will be included, if not it will be ignored.
        
        ,organizations.organization_tags as updater_organization_organization_tags
        
    from users

    
    left join organizations
        on users.source_relation = organizations.source_relation
        and users.organization_id = organizations.organization_id
    
)

select * 
from final
),  __dbt__cte__int_zendesk__field_history_enriched as (
with ticket_field_history as (

    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_field_history"

), updater_info as (
    select *
    from __dbt__cte__int_zendesk__updater_information

), final as (
    select
        ticket_field_history.*

          

    from ticket_field_history

    left join updater_info
        on ticket_field_history.user_id = updater_info.updater_user_id
        and ticket_field_history.source_relation = updater_info.source_relation
)
select *
from final
), field_history as (

    select
        source_relation,
        ticket_id,
        field_name,
        valid_ending_at,
        valid_starting_at

        --Only runs if the user passes updater fields through the final ticket field history model
        

        -- doing this to figure out what values are actually null and what needs to be backfilled in zendesk__ticket_field_history
        ,case when value is null then 'is_null' else value end as value

    from __dbt__cte__int_zendesk__field_history_enriched
    

), event_order as (

    select 
        *,
        row_number() over (
            partition by cast(valid_starting_at as date), ticket_id, field_name 
            order by valid_starting_at desc
            ) as row_num
    from field_history

), filtered as (

    -- Find the last event that occurs on each day for each ticket

    select *
    from event_order
    where row_num = 1

), pivots as (

    -- For each column that is in both the ticket_field_history_columns variable and the field_history table,
    -- pivot out the value into it's own column. This will feed the daily slowly changing dimension model.

    select
        source_relation, 
        ticket_id,
        cast(date_trunc('day', valid_starting_at) as date) as date_day

        
    
    from filtered
    group by 1,2,3

), surrogate_key as (

    select 
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ticket_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as ticket_day_id
    from pivots

)

select *
from surrogate_key
