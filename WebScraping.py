import requests
import pandas as pd

#URL for COVID-19 data in India
url = "https://api.covid19india.org/csv/latest/state_wise.csv"

#Send a GET request to the URL
response = requests.get(url)

#read the response as text
data = response.text

with open("covid_data.csv", "w") as file:
    file.write(data)


df = pd.read_csv("covid_data.csv")
df = df[['State', 'Confirmed', 'Deaths', 'Recovered', 'Active']]
print(df)