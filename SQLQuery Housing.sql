--Cleaning Data in SQL Queries

Select *
From HousingProject.dbo.NashvilleHousing


--Standardize Data format

Select SaleDateConverted,Convert(date,Saledate)
From HousingProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert( Date,SaleDate)


-- Populate Property Address data (using ParcelID)

Select *
From HousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL( a.PropertyAddress , b.PropertyAddress)
From HousingProject.dbo.NashvilleHousing a
Join HousingProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL( a.PropertyAddress , b.PropertyAddress)
From HousingProject.dbo.NashvilleHousing a
Join HousingProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


--Breaking out Address into Individual (Address ,City, State)


Select PropertyAddress
From HousingProject.dbo.NashvilleHousing
-- Where Project Address is null
-- order by ParcelID

Select 
substring (PropertyAddress , 1 ,Charindex(',' , PropertyAddress)-1) as Address,
substring (PropertyAddress,Charindex(',',PropertyAddress )+1 ,Len(PropertyAddress)) as Address
From HousingProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring (PropertyAddress , 1 ,Charindex(',' , PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = substring (PropertyAddress,Charindex(',',PropertyAddress )+1 ,Len(PropertyAddress))


Select *
From HousingProject.dbo.NashvilleHousing
Order by ParcelID


Select 
Parsename(replace(OwnerAddress,',','.'),3),
Parsename(replace(OwnerAddress,',','.'),2),
Parsename(replace(OwnerAddress,',','.'),1)
From HousingProject.dbo.NashvilleHousing
Order by ParcelID


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.'),3)



Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


Update NashvilleHousing
set OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)



Select *
From HousingProject.dbo.NashvilleHousing
order by 2



--Change Y and N to yes and No in " SoldAsVacant"

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From HousingProject.dbo.NashvilleHousing
group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From HousingProject.dbo.NashvilleHousing

Update NashvilleHousing 
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End


--Remove Duplicates


With RowNumCTE As (
Select *,
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From HousingProject.dbo.NashvilleHousing
--order by ParcelID
)
Select*
From RowNumCTE
Where row_num>1
Order by PropertyAddress


--Delete Unused Columns

Select *
From HousingProject.dbo.NashvilleHousing
Order by 2

Alter Table HousingProject.dbo. NashvilleHousing
Drop Column OwnerAddress ,TaxDistrict ,PropertyAddress

Alter Table HousingProject.dbo. NashvilleHousing
Drop Column SaleDate