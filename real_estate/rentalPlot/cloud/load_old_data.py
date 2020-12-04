# -*- coding: utf-8 -*-
"""
Created on Tue Oct  6 16:32:40 2020

@author: mbijlkh
"""

import pandas as pd
from utilities.helper import write_to_sql
df = pd.read_csv("../../rawDat_191028.csv")

#create two tables - condo_df and rent_df
condo_df = df.loc[:,['project','propertyType','street','x','y','district']]
condo_df.drop_duplicates(inplace = True)
#add index to condo_df
condo_df['CONDOID'] = range(1, len(condo_df) + 1)

condo_df.set_index('CONDOID', drop = False, inplace = True)

temp_df = pd.merge(df, condo_df[['project','propertyType','CONDOID']], how = 'left', on = ['project','propertyType'])

rent_df = temp_df.loc[:,['CONDOID','areaSqft','leaseDate','noOfBedRoom','rent','areaSqm','psf']]
rent_df['RENTID'] = range(1, len(rent_df) + 1)
rent_df.set_index('RENTID', drop = True, inplace = True)

condo_df.drop(columns = ['CONDOID'], inplace = True)

write_to_sql('admin', 'UKhmpajsMYzn2AhNFD5v', 'ura-rent.cm0lezxudqaz.ap-southeast-1.rds.amazonaws.com',
                    '3306', 'ura_rent', condo_df, 'condo_info', if_exists = 'replace', index = True)

write_to_sql('admin', 'UKhmpajsMYzn2AhNFD5v', 'ura-rent.cm0lezxudqaz.ap-southeast-1.rds.amazonaws.com',
                    '3306', 'ura_rent', rent_df, 'rent_info', if_exists = 'replace', index = True, chunksize = 5000)