with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        goal
,        start_date
,        end_date
,        status
,        budget
,        campaign_name
    from source
)
select * from renamed
