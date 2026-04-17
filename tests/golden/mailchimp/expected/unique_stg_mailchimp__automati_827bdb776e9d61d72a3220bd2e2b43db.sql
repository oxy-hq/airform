select
    automation_recipient_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_recipients"
where automation_recipient_id is not null
group by automation_recipient_id
having count(*) > 1
