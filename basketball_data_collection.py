import urllib
import pandas as pd
from bs4 import BeautifulSoup

url = 'http://kenpom.com/index.php'

def make_soup(url):
    page = urllib.urlopen(url)
    soup = BeautifulSoup(page,'html.parser')
    return soup

soup = make_soup(url)
team = []
seed = []
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
    if len(cells) >=1 and len(cells[1].find(class_='seed').get_text()) >=1:
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
adjem = map(float,adjem)
adjo = map(float,adjo)
adjd = map(float,adjd)
adjt = map(float,adjt)
luck = map(float,luck)
sosadjem = map(float,sosadjem)
sosoppo = map(float,sosoppo)
sosoppd = map(float,sosoppd)
adjemnc = map(float,adjemnc)


data = pd.DataFrame({'Team':team,'Seed':seed,'Efficiency Margin':adjem,'Offensive Efficiency':adjo,
                    'Defensive Efficiency': adjd,'Tempo':adjt,'Luck':luck,'Strength of Schedule':sosadjem,
                    'Opponent Offense':sosoppo,'Opponent Defense':sosoppd,'Non-Conference Strength of Schedule':adjemnc})
data = data[['Team','Seed','Efficiency Margin','Offensive Efficiency',
                    'Defensive Efficiency','Tempo','Luck','Strength of Schedule',
                    'Opponent Offense','Opponent Defense','Non-Conference Strength of Schedule']]
data.head()
