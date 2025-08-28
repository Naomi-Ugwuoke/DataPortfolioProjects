/*
Cleaning Data using SQL Queries
*/

SELECT * FROM PortfolioProject.NashvilleHousing;


-- Standardize the date format 

-- e.g April 9, 2013 => 2013-04-09
SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %e, %Y')
FROM PortfolioProject.NashvilleHousing;

-- SET SQL_SAFE_UPDATES = 0;	-- disable safe mode 
UPDATE PortfolioProject.NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y')
WHERE UniqueID IS NOT NULL;
/* SET SQL_SAFE_UPDATES = 1;	-- reenable safe mode */





-- Populate Property Address Data 

-- parcel id is linked to property address
SELECT a.UniqueID, a.ParcelID, a.PropertyAddress AS MissingAddress, 
       b.PropertyAddress AS SourceAddress
FROM PortfolioProject.NashvilleHousing a
JOIN PortfolioProject.NashvilleHousing b
  ON a.ParcelID = b.ParcelID 
  AND a.UniqueID <> b.UniqueID
WHERE (a.PropertyAddress IS NULL OR a.PropertyAddress='' ) AND (b.PropertyAddress IS NOT NULL OR b.PropertyAddress <>'');		-- to check which rows are being updated

UPDATE PortfolioProject.NashvilleHousing a
JOIN PortfolioProject.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE (a.PropertyAddress IS NULL OR a.PropertyAddress='' ) AND (b.PropertyAddress IS NOT NULL OR b.PropertyAddress <>'');	





-- Breaking out Address into Individual Columns (Address, City, State)

Select *
From PortfolioProject.NashvilleHousing
WHERE PropertyAddress IS NULL OR PropertyAddress='';

SELECT 
	TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)) AS Address,
	TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS City
FROM PortfolioProject.NashvilleHousing;

-- add columns
ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

-- update added columns
UPDATE NashvilleHousing
SET PropertySplitAddress = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)),
    PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));

-- owner address
ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET 
	OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
	OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
	OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

SELECT 
	UniqueID,
	PropertyAddress,
	PropertySplitAddress,
	PropertySplitCity,
	OwnerAddress,
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
FROM NashvilleHousing
LIMIT 100;





-- Change rows with Y/N to Yes/No in SoldAsVacant column

SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
	CASE SoldAsVacant
		WHEN 'Y' THEN 'Yes'
		WHEN 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS SoldAsVacantModified
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE SoldAsVacant
	WHEN 'Y' THEN 'Yes'
	WHEN 'N' THEN 'No'
	ELSE SoldAsVacant
END;





-- Remove Duplicates

SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ORDER BY UniqueID) AS RowNumber
FROM NashvilleHousing;

WITH RowNumsTable AS(
	SELECT *, 
		ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID) AS RowNumber
	FROM NashvilleHousing)
	SELECT * FROM RowNumsTable
	WHERE RowNumber > 1
	ORDER BY PropertyAddress;


DELETE FROM NashvilleHousing
WHERE UniqueID IN (
	SELECT UniqueID FROM(
		SELECT UniqueID, 
			ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			ORDER BY UniqueID) AS RowNumber
		FROM NashvilleHousing) AS RowNumsTable
	WHERE RowNumber > 1
);






-- Delete Unnecessary Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;