select
    automation_email_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_emails"
where automation_email_id is not null
group by automation_email_id
having count(*) > 1
