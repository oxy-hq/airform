with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        spend
,        end_date
,        goal
,        status
,        budget
,        campaign_name
,        start_date
    from source
)
select * from renamed
