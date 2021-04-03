# Data Mining projects

Hi! Thank you for coming to this page.
This folder holds two jupyter notebook files and .csv file. The notebooks have python code to that solves data mining problems.

1) ``2021-01-27-SQL-Skills.ipynb`` is a notebook showing how one could choose a new record to include in a digital music store using python, SQL and data analytics. Check the full rendered version in my blog: https://viniviena.github.io/ds-blog/sql/business/2021/01/27/SQL-Skills.html

2) ``crawler.py`` is a python code that scrap the http://www.thegoodscentscompany.com/ website to hunt molecules used in perfumery and their semantic descriptors! 
see my blog post showing how data science can help the perfumery industry. https://viniviena.github.io/ds-blog/cheminformatics/perfumes/machine%20learning/2021/02/15/Smells-PT.html


3) ``curated_ds.csv`` is the file I wrote after running the code and removing some words that have no semantic value from a perfumery perspective. Feel free to use it! There is nothing similar available in the web up do date (march 2021). There are 4 variables in this data set:

* ``cas_number`` is a molecule unique identifier that several chemical data bases uses (string)
* ``descriptors`` are the semantic descriptors that professional perfumers used to describe the odor characteristic of a molecule. (list of strings)
* ``smiles`` is a symbolic representation of the molecules that provide information about its atoms and their spatial arrangement. That notation is used worldwide to encode molecules into symbols. (string)
* ``pages`` is the page url from which I collected the information (string)
* ``desc_len`` is the size of the descriptor list. If you notice, some molecules have more descriptors than others! (int)


