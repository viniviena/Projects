!pip install beautifulsoup4
!pip install cirpy

import requests
from bs4 import BeautifulSoup
import re
import cirpy
import nltk
from nltk.corpus import stopwords
nltk.download('averaged_perceptron_tagger')
from nltk.stem.snowball import SnowballStemmer
from itertools import chain
import itertools
nltk.download('stopwords')

def get_url_list(alphabet_list):
    # Get url list containing all pages of components    
    url_list = []
    for letter in alphabet_list:
        url_list.append('http://www.thegoodscentscompany.com/fragonly' + '-' + letter +'.html')
    return url_list

def request_func(url):
    # returns a html parsed page
    pagef = requests.get(url)
    soup = BeautifulSoup(pagef.content, 'html.parser')
    return soup


def find_links(page, tag_name = 'table'):
    #returns hyperlinks from a html page
    tablet = page.find(name = tag_name)
    tags = []
    for item in tablet:
        if type(item.find('a')) != int:
          tags.append(item.find('a'))
    tags = [t for t in tags if t]
    links = [re.search("(?P<url>https?://[^\s]+)",t.attrs['onclick']).group("url")[0:-9] for t in tags]
    return links

def descriptor_formatter(raw_string):
  #Format the strings
    useless_words = ['provide', 'useful', 'note', 'notes', 'nuances', 'william', 'like', 
                     'scent', 'charact', 'fragranc','somewhat', 'real', 'thing','certain', 
                     'incred', 'sourc', 'almost', 'intens', 'background','aspect','care', 'home',
                     'masculin','odor', 'modern', 'fabric', 'good', 'make','sweet','except','usual',
                      'compound','full','also','ad','give','rich','use','similar','cost','arcadi','least','write',
                     'well', 'blend', 'cost','usag','type','tenaci','odour','import','cost','mark','intens', 'special','weak']

    descriptor_0 = re.findall(r'\b\w{4,10}\b', raw_string) #if comment is large throw out
    if len(descriptor_0) > 20:
       descriptor_final = []
    else:
      descriptor_1 = [word for word in descriptor_0 if not any(c.isdigit() for c in word)] #Verify if there is any digit
      descriptor_2 = [word for word in descriptor_1 if word not in stopwords.words('english')] #Remove stop words
      descriptor_3 = [word for word in descriptor_2 if word not in useless_words] #Remove words in useless_words list
      descriptor_4 = [SnowballStemmer("english").stem(word) for word in descriptor_3] #Stem words
      descriptor_final = [word for word in descriptor_4 if len(word) >= 3] #Drop small words
    #if nltk.pos_tag([word])[0][1] != 'JJ' 
    return descriptor_final




def cas_odor_url(url_chemical):
    #Implement the crawling
    descriptor_list = []
    descriptor_list_final = []
    page = request_func(url_chemical)
    if url_chemical != 'http://www.thegoodscentscompany.com/data/rw1109421.html':
        if page.find('table','cheminfo').find('tbody').find('td','radw11') is not None:
            cas_n = page.find('table','cheminfo').find('tbody').find('td','radw11').text
        else:
            cas_n = 'No Cas'
        
        tags_cheminfo = page.find_all('table', class_ = 'cheminfo')
        
        for tags in tags_cheminfo:
            #descriptor_list = []
            for tag in tags.find_all('td'):
                if (tag.has_attr('class')) and (tag.attrs['class'][0] == 'radw5'):
                    if 'Odor Description' in tag.get_text():
                        string = tag.get_text().replace('Odor Description:', '').lower()
                        descriptor = descriptor_formatter(string)
                        descriptor_list.append(descriptor)
                        #descriptor_list = itertools.chain(*descriptor_list)
                        #descriptor_list = list(chain.from_iterable(descriptor_list))
                        #descriptor_list = list(set(descriptor_list))
                        descriptor_list_final = list(set(itertools.chain(*descriptor_list)))
                        #print(descriptor_list_final)

        if cas_n != 'No Cas':
          if cirpy.resolve(cas_n, 'smiles'):
              smiles_str = cirpy.resolve(cas_n, 'smiles')
          else:
                smiles_str = 'No Smiles'
        else:
            if cirpy.resolve(cas_n, 'smiles'):
              smiles_str = cirpy.resolve(cas_n, 'smiles')
            else:
                smiles_str = 'No Smiles'

        output_dict = {'cas_number': cas_n, 'descriptors':descriptor_list_final, 'smile_string':smiles_str, 'page':url_chemical}
    else:
        print('No page')
        output_dict = {'cas_number': 'No Page', 'descriptors':'No Page', 'smile_string':'No Page', 'page':'No Page'}  
    return output_dict



alphabet_list = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 
                 'i', 'jk', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
                 's', 't', 'u', 'v', 'wx', 'y', 'z']


cas_numbers = []
descriptors = []
smile_strings = []
pages = []
url_list = get_url_list(alphabet_list)
feed_dict = {'cas_number': cas_numbers, 'descriptors': descriptors, 'smiles':smile_strings, 'pages': pages}
(i,j,k) = (0,0,0)
for url in url_list:
    print('url:',str(i))
    i += 1
    parsed_page = request_func(url)
    list_of_pages = find_links(parsed_page)
    for pages in list_of_pages:
        k+=1
        info = cas_odor_url(pages)
        feed_dict['cas_number'].append(info['cas_number'])
        feed_dict['descriptors'].append(info['descriptors'])
        feed_dict['smiles'].append(info['smile_string'])
        feed_dict['pages'].append(info['page'])
        print('total requests', k)