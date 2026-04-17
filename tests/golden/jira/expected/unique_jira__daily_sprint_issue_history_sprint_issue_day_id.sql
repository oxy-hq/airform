select
    sprint_issue_day_id as unique_field,
    count(*) as n_records

from "jira"."main_jira"."jira__daily_sprint_issue_history"
where sprint_issue_day_id is not null
group by sprint_issue_day_id
having count(*) > 1
