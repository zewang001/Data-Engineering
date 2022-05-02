# Build a pipeline to find out how many records are in the shortest of the seasonal data files.
#	1 Use wc with appropriate parameters to list the number of lines in all of the seasonal data files. (Use a wildcard for the filenames instead of typing them all in by hand.)
#	2 Add another command to the previous one using a pipe to remove the line containing the word "total".
#	3 Add two more stages to the pipeline that use sort -n and head -n 1 to find the file containing the fewest lines.

wc -l seasonal/*
  
wc -l seasonal/* | grep -v total
  
wc -l seasonal/* | grep -v total | sort -n | head -n1
##########################################################################################################################  
#csvkit  

#The Excel file Spotify_201809_201810.xlsx contains two sheets (tabs), named Spotify201809 and Spotify201810. First, we will split the Excel file down to its 
#individual sheets, preview summary statistics, remove some columns, and then stack the two sheets back together again to form one single csv file, ready for 
#further analysis.  
  
# Convert the Spotify201809 tab into its own csv file 
in2csv Spotify_201809_201810.xlsx --sheet "Spotify201809" > Spotify201809.csv

# Check to confirm name and location of data file
ls

# Preview file preview using a csvkit function
csvlook Spotify201809.csv

# Create a new csv with 2 columns: track_id and popularity
csvcut -c "track_id","popularity" Spotify201809.csv > Spotify201809_subset.csv

# While stacking the 2 files, create a data source column
csvstack -g "Sep2018","Oct2018" Spotify201809_subset.csv Spotify201810_subset.csv > Spotify_all_rankings.csv

#############################################################################################################
# cron scheduler

# Preview both Python script and requirements text file
cat create_model.py
cat requirements.txt

# Pip install Python dependencies in requirements file
pip install -r requirements.txt 

# Run Python script on command line
python create_model.py

# Add CRON job that runs create_model.py every minute
echo "* * * * * python create_model.py" | crontab

# Verify that the CRON job has been scheduled via CRONTAB
crontab -l
----------------------------------------------------------
import pandas as pd
import pickle
from sklearn.ensemble import RandomForestClassifier

df_train = pd.read_csv("trainexit.csv")
df_train.dropna(inplace=True)
df_train = df_train.drop(['PassengerId', 'Name', 'Cabin', 'Ticket'], axis=1)

df_train = pd.get_dummies(df_train)
df_train = df_train.drop(['Sex_female', 'Embarked_C'], axis=1)

X = df_train.drop('Survived', axis = 1)
y = df_train['Survived']

model = RandomForestClassifier()
model.fit(X, y)

model_filename = 'model.pkl'
with open(model_filename, 'wb') as f:
    pickle.dump(model, f)
------------------------------------------    
scikit-learn==0.20.2
scipy==1.2.0
sklearn==0.0Collecting 
scikit-learn==0.20.2
