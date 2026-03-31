with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as ticket_id,
        user_id,
        account_id,
        agent_id,
        category,
        priority,
        subject,
        status,
        created_at,
        resolved_at,
        first_response_at,
        csat_score
    from source
)

select * from renamed
