select
    automation_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automations"
where automation_id is not null
group by automation_id
having count(*) > 1
