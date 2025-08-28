Nashville Housing Data Cleaning Project

This project demonstrates how to clean and prepare raw housing data using SQL.
The dataset comes from Nashville’s open housing data and was cleaned to make it more usable for analysis, visualization, and reporting.

Project Goals
- Standardize inconsistent formats
- Handle missing and duplicate data
- Break down compound fields into more usable columns
- Improve data quality for further analysis in tools like Tableau or Power BI


Steps Performed

1. Standardized Date Format
   - Converted dates from text format (e.g., April 9, 2013) → SQL DATE format (YYYY-MM-DD).

2. Populated Missing Property Addresses
   - Used ParcelID as a key to fill in missing property addresses by joining against rows with the same parcel.

3. Split Address Columns
   Broke PropertyAddress into:
   - PropertySplitAddress (street address)
   - PropertySplitCity (city)
   Broke OwnerAddress into:
   - OwnerSplitAddress
   - OwnerSplitCity
   - OwnerSplitState

4. Standardized “SoldAsVacant” Column
   - Replaced ambiguous values (Y / N) with clearer values (Yes / No).

5. Removed Duplicates
   - Identified duplicates using ROW_NUMBER() with PARTITION BY.
   - Deleted duplicate rows, keeping only the first occurrence.

6. Dropped Unnecessary Columns
   - Removed OwnerAddress, TaxDistrict, and original PropertyAddress columns since they were split into cleaner fields.
