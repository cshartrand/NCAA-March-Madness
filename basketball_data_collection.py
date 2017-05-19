import urllib
import pandas as pd
from bs4 import BeautifulSoup

def make_soup(url):
    page = urllib.urlopen(url)
    soup = BeautifulSoup(page,'html.parser')
    return soup

url_main = 'http://kenpom.com/index.php'
url_extension = '?y='
years = ['2017','2016','2015','2014','2013','2012','2011','2010','2009','2008','2007','2006','2005','2004','2003','2002']

for i in range(0,len(years)):

    if i == 0:
        url = url_main
    else:
        url = url_main + url_extension + years[i]

    soup = make_soup(url)
    team = []
    seed = []
    year = []
    adjem = []
    adjo = []
    adjd = []
    adjt = []
    luck = []
    sosadjem = []
    sosoppo = []
    sosoppd = []
    adjemnc = []

    rows = soup.select('tbody tr')
    for row in soup.select('tbody tr'):
        cells = row.findAll('td')
        if len(cells) >=1 and len(cells[1].find(class_='seed').get_text()) >=1: #make sure if grabs correct rows and not column headers or teams that did not make the tournament
            team.append(cells[1].find(text=True))
            seed.append(cells[1].find(class_='seed').get_text())
            adjem.append(cells[4].find(text=True))
            adjo.append(cells[5].find(text=True))
            adjd.append(cells[7].find(text=True))
            adjt.append(cells[9].find(text=True))
            luck.append(cells[11].find(text=True))
            sosadjem.append(cells[13].find(text=True))
            sosoppo.append(cells[15].find(text=True))
            sosoppd.append(cells[17].find(text=True))
            adjemnc.append(cells[19].find(text=True))

    team = map(str,team)
    seed = map(int,seed)
    year = [years[i]] * len(team)
    adjem = map(float,adjem)
    adjo = map(float,adjo)
    adjd = map(float,adjd)
    adjt = map(float,adjt)
    luck = map(float,luck)
    sosadjem = map(float,sosadjem)
    sosoppo = map(float,sosoppo)
    sosoppd = map(float,sosoppd)
    adjemnc = map(float,adjemnc)
    #mapping each metric back to the appropriate data type

    temp = pd.DataFrame({'Team':team,'Seed':seed,'Year':year,'Efficiency Margin':adjem,'Offensive Efficiency':adjo,
                        'Defensive Efficiency': adjd,'Tempo':adjt,'Luck':luck,'Strength of Schedule':sosadjem,
                        'Opponent Offense':sosoppo,'Opponent Defense':sosoppd,'Non-Conference Strength of Schedule':adjemnc})
    temp = temp[['Team','Seed','Year','Efficiency Margin','Offensive Efficiency',
                        'Defensive Efficiency','Tempo','Luck','Strength of Schedule',
                        'Opponent Offense','Opponent Defense','Non-Conference Strength of Schedule']]

    if i == 0:
        data = temp
        #create the first instance of the dataset, using 2017 as first year
    else:
        data = data.append(temp)
        #append data from each previous year of Pomeroy's College Basketball Ratings

data.to_csv('ncaa-team-data.csv') #write out the dataset to use for modeling
