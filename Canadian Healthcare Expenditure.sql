-- All data in these tables are in current millions of dollars, 
-- the data has also been cleaned and reorganized in excel prior to being imported

select * from hcecanada h 

-- Renaming our Province/Territory & "Year" columns 

ALTER TABLE public.hcecanada RENAME COLUMN "Province/Territory" TO prov_terr;
ALTER TABLE public.hcecanada RENAME COLUMN "Year" TO year;

-- Altering the table to add a 'Region' column accounting for the 5 distinct regions of Canada
-- and subsequently updating the new column to match each province/territory

alter table hcecanada add region VARCHAR(20);

update hcecanada 
set region = 'Central' where prov_terr in ('Ont.','Que.');

update hcecanada 
set region = 'Atlantic' where prov_terr in ('N.L.','P.E.I.','N.S.','N.B.');

update hcecanada 
set region = 'Prairie' where prov_terr in ('Man.','Sask.','Alb.');

update hcecanada 
set region = 'Western' where prov_terr in ('B.C.');

update hcecanada 
set region = 'Northern' where prov_terr in ('Nun.','Yuk.','N.W.T.');


-- Looking to see the percentage of healthcare expended on drugs per year for each province/territory

select year, prov_terr, drugs, total, ((drugs*1.0/nullif(total,0)*100)) as Percent_Spent_Drugs
from hcecanada h 

-- The % of Healthcare funds spent on drugs per year across the entirety of Canada 

select year, sum(drugs) as drugs, sum(total) as total, ((sum(drugs)*1.0/nullif(sum(total),0)*100)) as PercentSpentOnDrugs
from hcecanada h 
group by year 
order by year 

-- The toal Healthcare spending per province/territory from 1975 - 2022 

select prov_terr, sum(total) as total  
from hcecanada h 
group by prov_terr
order by total desc 

-- Looking for the single year the most money was spent on administration 
-- costs, in which province/territory as well as what percentage of the total expenditure that year 

select year, prov_terr, h2.administration, total,
((h2.administration *1.0/nullif(total,0)*100)) as Percent_Spent_Admin
from hcecanada h2 
inner join (
	select MAX(administration) administration 
	from hcecanada h2
)MaxAdminSpent
on MaxAdminSpent.administration = h2.administration 

-- Looking at the percentage spent on hospitals vs other institutions per province 

select prov_terr, sum(hospitals) as Hospital,((sum(hospitals)*1.0/nullif(sum(total),0)*100)) as PercentHospitals, 
sum(Other_Institutions) as OtherInstitutions,
((sum(Other_Institutions)*1.0/nullif(sum(total),0)*100)) as PercentOtherInstitutions,
sum(total) as total
from hcecanada h 
group by prov_terr
order by prov_terr 

-- Looking at the percentage spent on physicians vs other professionals per province 
select prov_terr, sum(physicians) as Physicians, 
((sum(physicians)*1.0/nullif(sum(total),0)*100)) as PercentPhysicians, 
sum(Other_Professionals) as OtherProfessionals,
((sum(Other_Professionals)*1.0/nullif(sum(total),0)*100)) as PercentOtherProfessionals,
sum(total) as total
from hcecanada h 
group by prov_terr
order by prov_terr 

-- Turning the last few queries into views to store for future data visualizations

create view PercentPhysiciansvsOtherProfessionals as
select prov_terr, sum(physicians) as Physicians, sum(Other_Professionals) as OtherProfessionals,
sum(total) as total, ((sum(physicians)*1.0/nullif(sum(total),0)*100)) as PercentPhysicians, 
((sum(Other_Professionals)*1.0/nullif(sum(total),0)*100)) as PercentOtherProfessionals
from hcecanada h 
group by prov_terr
order by prov_terr 

create view PercentHospitalsvsOtherInstitutions as
select prov_terr, sum(hospitals) as Hospital, sum(Other_Institutions) as OtherInstitutions,
sum(total) as total, ((sum(hospitals)*1.0/nullif(sum(total),0)*100)) as PercentHospitals, 
((sum(Other_Institutions)*1.0/nullif(sum(total),0)*100)) as PercentOtherInstitutions
from hcecanada h 
group by prov_terr
order by prov_terr 

create view PercentageSpentOnDrugs as
select year, prov_terr, sum(drugs) as drugs, sum(total) as total, ((sum(drugs)*1.0/nullif(sum(total),0)*100)) as PercentSpentOnDrugs
from hcecanada h 
group by prov_terr, year 
order by year 

create view TotalHCE as
select prov_terr, sum(total) as total  
from hcecanada h 
group by prov_terr
order by total desc 