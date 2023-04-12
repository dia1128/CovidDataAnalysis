Select location, date, total_cases, new_cases, total_deaths, population FROM coviddeath
order by 1,2;

-- Looking at Total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100
as DeathPercentage
FROM coviddeath
Where location like '%states%'
order by 1,2;

-- Looking at the Total Cases VS Population
-- shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100
as CasePercentage
FROM coviddeath
Where location like '%states%'
order by 1,2;

-- Looking at Coutnries with highest infection rate compared to population
Select Location, Population, Max(total_cases) as InfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeath
Group by Location, Population
order by PercentPopulationInfected desc;


-- Showing continents with highest deathcounts
Select continent, max(total_deaths) as TotalDeathCount
from coviddeath where continent <> ''
Group by continent
order by TotalDeathCount desc;


-- Global Numbers
Select cast(date as Date), SUM(new_cases) , SUM(new_deaths)
from coviddeath
where continent <> ''
Group by date
Order by 1,2;


-- FIXING DATE
-- Fixing the Date column in covidDate


----------------------------------------------------------------------
Create Table temp_coviddeat (
date_new VARCHAR(50)
);

ALTER TABLE coviddeath DROP COLUMN date;
Describe coviddeath;


Alter Table temp_coviddeat ADD id INT AUTO_INCREMENT Primary KEY;


Alter Table coviddeath Add Column date Varchar(50);


Select * From temp_date;
Alter Table temp_date Add Column id Int auto_increment Primary Key;


Update coviddeath
Set coviddeath.date = (
 Select temp_date.date
 From temp_date
 WHERE temp_date.id = coviddeath.id

);

Select date from coviddeath;

SELECT STR_TO_DATE(temp_date.date, '%d/%m/%Y') AS my_date
FROM temp_date
WHERE temp_date.date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
ORDER BY my_date;

SELECT CAST(temp_date.date AS DATE) AS my_date
FROM temp_date
WHERE TRIM(temp_date.date) <> ''
ORDER BY my_date;

SELECT COUNT(*) AS total_rows, COUNT(date) AS non_null_rows
FROM temp_date;

UPDATE coviddeath SET date = STR_TO_DATE(date, '%m/%d/%y');
UPDATE covidvaccinations SET date = STR_TO_DATE(date, '%m/%d/%y');

SELECT new_cases, date
FROM coviddeath
ORDER BY STR_TO_DATE(date, '%m/%d/%y');

Update covidvaccinations
Set covidvaccinations.date = (
 Select coviddeath.date
 From coviddeath
 WHERE covidvaccinations.id = coviddeath.id

);
SELECT date, total_cases from covidvaccinations
ORDER BY STR_TO_DATE(date, '%m/%d/%y');

--------------------------------------------------------------------------

-- Done fixing the Date column


Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeath
where continent <> ''
order by 1,2;



-- Looking at total population vs vaccinations
-- Use CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeath dea
Join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent <> ''

)

Select *, Continent, (RollingPeopleVaccinated/Population)*100 as VaccinatedPerLocation 
From PopvsVac
Where Continent like '%Europe%' And Location like '%Albania%';


-- Insert
Drop Table if exists PercentPopulationVaccinated ;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeath dea
Join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date;


Select *, (RollingPeopleVaccinated/Population)*100 From PercentPopulationVaccinated;

-- View

Create View PercentVaccinated as  
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From coviddeath dea
Join covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent <> '';



 




