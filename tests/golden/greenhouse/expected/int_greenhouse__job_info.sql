with hiring_team as (

    select *
    from __dbt__cte__int_greenhouse__hiring_team
),

job as (

    select *
    from main_stg_greenhouse.stg_greenhouse__job
),


job_office as (

    select *
    from __dbt__cte__int_greenhouse__job_offices
),



job_department as (

    select *
    from __dbt__cte__int_greenhouse__job_departments
),


final as (

    select 
        job.*,
        hiring_team.hiring_managers,
        hiring_team.sourcers,
        hiring_team.recruiters,
        hiring_team.coordinators

        
        ,
        job_office.offices,
        job_office.locations as office_locations
        

        
        ,
        job_department.departments,
        job_department.parent_departments
        

    from job
    left join hiring_team
        on job.job_id = hiring_team.job_id
        and job.source_relation = hiring_team.source_relation

    
    left join job_office
        on job.job_id = job_office.job_id
        and job.source_relation = job_office.source_relation
    

    
    left join job_department
        on job.job_id = job_department.job_id
        and job.source_relation = job_department.source_relation
    
)

select *
from final
