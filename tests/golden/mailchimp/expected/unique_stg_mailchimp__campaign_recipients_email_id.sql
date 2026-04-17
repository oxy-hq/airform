select
    email_id as unique_field,
    count(*) as n_records

from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__campaign_recipients"
where email_id is not null
group by email_id
having count(*) > 1
