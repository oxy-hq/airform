select
    activity_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_activities"
where activity_id is not null
group by activity_id
having count(*) > 1
