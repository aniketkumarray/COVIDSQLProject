SELECT LOCATION, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking for TOT cases VS TOT Deaths
--shows likelihood of dying if you have covid
SELECT location, date, total_cases, total_deaths,  ((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100)  AS DeathPercentages
FROM PortfolioProject..CovidDeath
WHERE location = 'India'
ORDER BY 1,2;

-- tot cases vs population
--% of population got covid
SELECT location, date, total_cases, population,  ((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100)  AS CasesPercentages
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2;


--Looking at countries with higest infection rate compared to population
SELECT location, MAX(total_cases) AS Higest_Infection_Count, population,  MAX(((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100))  AS CasesPercentages
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY CasesPercentages DESC;

--Countries with higest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

--Checking the continent data

SELECT 
    location, 
    MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM 
    PortfolioProject..CovidDeath 
WHERE 
     location IN ('Europe','Asia','North America','South America','Africa')

GROUP BY location
ORDER BY 
    Total_Death_Count DESC;
	--Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
where continent is not null 
--Group By date
order by 1,2


--joining death and vaccination tables
--looking at tot population Vs vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location Order By dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND	dea.date=vac.date
WHERE dea.continent IS NOT NULL
Order BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location Order By dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND	dea.date=vac.date
WHERE dea.continent IS NOT NULL

)
Select *, (RollingPeopleVaccinated/Population)*100 AS Percent_Rolling_People_Vaccinated
From PopvsVac
WHERE continent IS NOT NULL
ORDER BY 2,3