/* 

Cleaning Data in SQL

*/

SELECT * FROM PortfolioProject.nashvillehousing;

---------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT saledate,
STR_TO_DATE(SaleDate, '%M %d, %Y')
FROM PortfolioProject.nashvillehousing;

UPDATE PortfolioProject.nashvillehousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

---------------------------------------------------------------------------------------

-- Populate Property Address Data

-- Checked for nulls.There were no NULLS

SELECT COUNT(*),PropertyAddress,parcelid
FROM PortfolioProject.nashvillehousing
WHERE PropertyAddress is null
GROUP BY 2,3
ORDER BY PropertyAddress;

-- Checked for blanks.There were blanks #29

SELECT COUNT(*),PropertyAddress,parcelid
FROM PortfolioProject.nashvillehousing
WHERE PropertyAddress = ''
GROUP BY 2,3
ORDER BY PropertyAddress;

-- Count of blanks - #29

SELECT COUNT(*)
FROM PortfolioProject.nashvillehousing
WHERE PropertyAddress = '';

-- Updated the Blanks to Nulls

UPDATE PortfolioProject.nashvillehousing
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

-- Checked data for a Propertyid having the same parcelid and different uniqueid

SELECT PropertyAddress,parcelid, uniqueid
FROM PortfolioProject.nashvillehousing
WHERE parcelid  = '025 07 0 031.00';

-- Self Join query to populate the Null Property Addresses

SELECT a.PropertyAddress,a.parcelid,b.PropertyAddress,b.parcelid,ifnull(a.PropertyAddress,b.PropertyAddress)
FROM portfolioProject.nashvillehousing a
JOIN portfolioProject.nashvillehousing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress is null;

-- Update query to populate the Populate Null Property Addresses

UPDATE portfolioProject.nashvillehousing a
JOIN portfolioProject.nashvillehousing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
SET a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress is null;

---------------------------------------------------------------------------------------

-- Breaking out PropertyAddress into individual columns (Address, City)

SELECT propertyaddress, 
SUBSTRING(propertyaddress,1,INSTR(propertyaddress,',')-1) as Address,
SUBSTRING(propertyaddress,INSTR(propertyaddress,',')+1) as City
FROM portfolioProject.nashvillehousing;

-- Adding new columns Address and City to the table

ALTER TABLE portfolioProject.nashvillehousing
ADD PropertySplitAddress text;

ALTER TABLE portfolioProject.nashvillehousing
ADD PropertySplitCity text;

-- Updating new columns

UPDATE portfolioProject.nashvillehousing
SET PropertySplitAddress = SUBSTRING(propertyaddress,1,INSTR(propertyaddress,',')-1);

UPDATE portfolioProject.nashvillehousing
SET PropertySplitCity = SUBSTRING(propertyaddress,INSTR(propertyaddress,',')+1);

---------------------------------------------------------------------------------------

-- Breaking out OwnerAddress into individual columns ( Address, City, State)

SELECT 
SUBSTRING_INDEX(owneraddress,',',1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress,',',2),',',-1) as City,
SUBSTRING_INDEX(owneraddress,',',-1) as State
FROM portfolioProject.nashvillehousing;

-- Adding new columns Address, City and State to the table

ALTER TABLE portfolioProject.nashvillehousing
ADD OwnerSplitAddress text;

ALTER TABLE portfolioProject.nashvillehousing
ADD OwnerSplitCity text;

ALTER TABLE portfolioProject.nashvillehousing
ADD OwnerSplitState text;

-- Updating new columns

UPDATE portfolioProject.nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(owneraddress,',',1);

UPDATE portfolioProject.nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(substring_index(owneraddress,',',2),',',-1);

UPDATE portfolioProject.nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(owneraddress,',',-1);

---------------------------------------------------------------------------------------

-- Change Y and N to yes and No in 'Sold as Vacant' field

SELECT COUNT(*), soldasvacant
FROM portfolioProject.nashvillehousing
GROUP BY 2
ORDER BY 1;

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant
	 END
FROM portfolioProject.nashvillehousing;

-- Update the 'Sold as Vacant' field

UPDATE portfolioProject.nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' then 'Yes'
						WHEN soldasvacant = 'N' then 'No'
						ELSE soldasvacant
						END;

---------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY parcelid,propertyaddress,saleprice,saledate,legalreference ORDER BY uniqueid) as row_num
FROM portfolioProject.nashvillehousing
ORDER BY parcelid
)
DELETE FROM portfolioProject.nashvillehousing
WHERE uniqueid IN (
  SELECT uniqueid
  FROM RowNumCTE
  WHERE row_num > 1);
  
  ---------------------------------------------------------------------------------------
  
  -- Delete unused columns
  
ALTER TABLE portfolioProject.nashvillehousing
DROP COLUMN propertyaddress,
DROP COLUMN taxdistrict,
DROP COLUMN owneraddress;
  
  
  
  
  