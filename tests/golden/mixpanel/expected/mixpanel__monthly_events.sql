with events as (

    select 
        source_relation,
        event_type,
        occurred_at,
        unique_event_id,
        people_id,
        cast( date_trunc('month', occurred_at) as date) as date_month

    from "mixpanel"."main_mixpanel"."mixpanel__event"

    
),

month_totals as (
    
    select 
        source_relation,
        date_month,
        count(distinct people_id) as total_monthly_active_users
    from events
    group by 1,2
),

sub as (
-- aggregate number of events to the month
        select
            source_relation,
            people_id,
            event_type,
            date_month,
            count(unique_event_id) as number_of_events

        from events
        group by 1,2,3,4
), 

user_monthly_events as (

    select 
        *, 
        -- first time a user did this kind of event
        min(date_month) over(partition by people_id, event_type, source_relation) as first_month,

        -- last month that the user performed this kind of event during
        lag(date_month, 1) over(partition by people_id, event_type, source_relation order by date_month asc) previous_month_with_event

    from sub
),

monthly_metrics as (

    select 
        user_monthly_events.source_relation,
        user_monthly_events.date_month,
        user_monthly_events.event_type,
        month_totals.total_monthly_active_users,

        count(distinct user_monthly_events.people_id) as number_of_users,
        count( distinct case when user_monthly_events.first_month = user_monthly_events.date_month then user_monthly_events.people_id end) as number_of_new_users,

        -- defining repeat user as someone who also performed this action the previous month
        count(distinct case when user_monthly_events.previous_month_with_event is not null and 
            date_diff('month', user_monthly_events.previous_month_with_event::timestamp, user_monthly_events.date_month::timestamp ) = 1
            then user_monthly_events.people_id end) as number_of_repeat_users,

        -- defining return user as someone who has performed this action farther in the past
        count(distinct case when user_monthly_events.previous_month_with_event is not null and
            date_diff('month', user_monthly_events.previous_month_with_event::timestamp, user_monthly_events.date_month::timestamp ) > 1
            then user_monthly_events.people_id end) as number_of_return_users,

        sum(user_monthly_events.number_of_events) as number_of_events

    from user_monthly_events
        left join month_totals 
            on user_monthly_events.source_relation = month_totals.source_relation
            and user_monthly_events.date_month = month_totals.date_month
    group by 1,2,3,4
),

-- add churn!
final as (

    select
        *,

        -- subtract the returned users from the previous month's total users to get the # churned
        -- note: churned users refer to users who did something last month and not this month
        coalesce(lag(number_of_users, 1) over(partition by event_type, source_relation order by date_month asc) - number_of_repeat_users, 0) as number_of_churn_users,
        date_month || '-' || event_type || '-' || source_relation as unique_key, -- for incremental model :)
        current_date as dbt_run_date

    from monthly_metrics
)

select * from final
